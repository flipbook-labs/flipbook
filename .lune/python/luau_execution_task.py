# upstream: https://raw.githubusercontent.com/Roblox/place-ci-cd-demo/refs/heads/production/scripts/python/luau_execution_task.py

import argparse
import logging
import urllib.request
import urllib.error
import base64
import sys
import json
import time
import hashlib
import os


def parseArgs():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-k",
        "--api-key",
        help="Path to a file containing your OpenCloud API key. You can also use the environment variable RBLX_OC_API_KEY to specify the API key. This option takes precedence over the environment variable.",
        metavar="<path to API key file>",
    )
    parser.add_argument(
        "-u",
        "--universe",
        "-e",
        "--experience",
        required=True,
        help="ID of the experience (a.k.a. universe) containing the place you want to execute the task against.",
        metavar="<universe id>",
        type=int,
    )
    parser.add_argument(
        "-p",
        "--place",
        required=True,
        help="ID of the place you want to execute the task against.",
        metavar="<place id>",
        type=int,
    )
    parser.add_argument(
        "-v",
        "--place-version",
        help="Version of the place you want to execute the task against. If not given, the latest version of the place will be used.",
        metavar="<place version>",
        type=int,
    )
    parser.add_argument(
        "-f",
        "--script-file",
        required=True,
        help="Path to a file containing your Luau script.",
        metavar="<path to Luau script file>",
    )
    parser.add_argument(
        "-c",
        "--continuous",
        help="If specified, this script will run in a loop and automatically create a new task after the previous task has finished, but only if the script file is updated. If the script file has not been updated, this script will wait for it to be updated before submitting a new task.",
        action="store_true",
    )
    parser.add_argument(
        "-o",
        "--output",
        help="Path to a file to write the task's output to. If not given, output is written to stdout.",
        metavar="<path to output file>",
    )
    parser.add_argument(
        "-l",
        "--log-output",
        help="Path to a file to write the task's logs to. If not given, logs are written to stderr.",
        metavar="<path to log output file>",
    )

    return parser.parse_args()


def makeRequest(url, headers, body=None):
    data = None
    if body is not None:
        data = body.encode("utf8")
    request = urllib.request.Request(
        url, data=data, headers=headers, method="GET" if body is None else "POST"
    )
    max_attempts = 3
    for i in range(max_attempts):
        try:
            return urllib.request.urlopen(request)
        except Exception as e:
            if "certificate verify failed" in str(e):
                logging.error(
                    f"{str(e)} - you may need to install python certificates, see https://stackoverflow.com/questions/27835619/urllib-and-ssl-certificate-verify-failed-error"
                )
                sys.exit(1)
            if i == max_attempts - 1:
                raise e
            else:
                logging.info(f"Retrying error: {str(e)}")
                time.sleep(1)


def readFileExitOnFailure(path, file_description):
    try:
        with open(path, "r") as f:
            return f.read()
    except FileNotFoundError:
        logging.error(f"{file_description.capitalize()} file not found: {path}")
    except IsADirectoryError:
        logging.error(f"Invalid {file_description} file: {path} is a directory")
    except PermissionError:
        logging.error(f"Permission denied to read {file_description} file: {path}")
    sys.exit(1)


def loadAPIKey(api_key_arg):
    source = ""
    if api_key_arg:
        api_key_arg = api_key_arg.strip()
        source = f"file {api_key_arg}"
        key = readFileExitOnFailure(api_key_arg, "API key").strip()
    else:
        if "RBLX_OC_API_KEY" not in os.environ:
            logging.error(
                "API key needed. Either provide the --api-key option or set the RBLX_OC_API_KEY environment variable."
            )
            sys.exit(1)
        source = "environment variable RBLX_OC_API_KEY"
        key = os.environ["RBLX_OC_API_KEY"].strip()

    try:
        base64.b64decode(key, validate=True)
        return key
    except Exception as e:
        logging.error(
            f"API key appears invalid (not valid base64, loaded from {source}): {str(e)}"
        )
        sys.exit(1)


def createTask(api_key, script, universe_id, place_id, place_version):
    headers = {"Content-Type": "application/json", "x-api-key": api_key}
    data = {"script": script}
    url = f"https://apis.roblox.com/cloud/v2/universes/{universe_id}/places/{place_id}/"
    if place_version:
        url += f"versions/{place_version}/"
    url += "luau-execution-session-tasks"

    try:
        response = makeRequest(url, headers=headers, body=json.dumps(data))
    except urllib.error.HTTPError as e:
        logging.error(f"Create task request failed, response body:\n{e.fp.read()}")
        sys.exit(1)

    task = json.loads(response.read())
    return task


def pollForTaskCompletion(api_key, path):
    headers = {"x-api-key": api_key}
    url = f"https://apis.roblox.com/cloud/v2/{path}"

    logging.info("Waiting for task to finish...")

    while True:
        try:
            response = makeRequest(url, headers=headers)
        except urllib.error.HTTPError as e:
            logging.error(f"Get task request failed, response body:\n{e.fp.read()}")
            sys.exit(1)

        task = json.loads(response.read())
        if task["state"] != "PROCESSING":
            sys.stderr.write("\n")
            sys.stderr.flush()
            return task
        else:
            sys.stderr.write(".")
            sys.stderr.flush()
            time.sleep(3)


def getTaskLogs(api_key, task_path):
    headers = {"x-api-key": api_key}
    url = f"https://apis.roblox.com/cloud/v2/{task_path}/logs"

    try:
        response = makeRequest(url, headers=headers)
    except urllib.error.HTTPError as e:
        logging.error(f"Get task logs request failed, response body:\n{e.fp.read()}")
        sys.exit(1)

    logs = json.loads(response.read())
    messages = logs["luauExecutionSessionTaskLogs"][0]["messages"]
    return "".join([m + "\n" for m in messages])


def handleLogs(task, log_output_file_path, api_key):
    logs = getTaskLogs(api_key, task["path"])
    if logs:
        if log_output_file_path:
            with open(log_output_file_path, "w") as f:
                f.write(logs)
            logging.info(f"Task logs written to {log_output_file_path}")
        else:
            logging.info(f"Task logs:\n{logs.strip()}")
    else:
        logging.info("The task did not produce any logs")


def handleSuccess(task, output_path):
    output = task["output"]
    if output["results"]:
        if output_path:
            with open(output_path, "w") as f:
                f.write(json.dumps(output["results"]))
            logging.info(f"Task results written to {output_path}")
        else:
            logging.info("Task output:")
            print(json.dumps(output["results"]))
    else:
        logging.info("The task did not return any results")


def handleFailure(task):
    logging.error(f'Task failed, error:\n{json.dumps(task["error"])}')


if __name__ == "__main__":
    logging.basicConfig(
        format="[%(asctime)s] [%(name)s] [%(levelname)s]: %(message)s",
        level=logging.INFO,
    )

    args = parseArgs()

    api_key = loadAPIKey(args.api_key)

    waiting_msg_printed = False
    prev_script_hash = None
    while True:
        script = readFileExitOnFailure(args.script_file, "script")
        script_hash = hashlib.sha256(script.encode("utf8")).hexdigest()

        if prev_script_hash is not None and script_hash == prev_script_hash:
            if not waiting_msg_printed:
                logging.info("Waiting for changes to script file...")
                waiting_msg_printed = True
            time.sleep(1)
            continue

        if prev_script_hash is not None:
            logging.info("Detected change to script file, submitting new task")

        prev_script_hash = script_hash
        waiting_msg_printed = False

        task = createTask(
            api_key, script, args.universe, args.place, args.place_version
        )
        logging.info(f"Task created, path: {task['path']}")

        task = pollForTaskCompletion(api_key, task["path"])
        logging.info(f'Task is now in {task["state"]} state')

        handleLogs(task, args.log_output, api_key)
        if task["state"] == "COMPLETE":
            handleSuccess(task, args.output)
        else:
            handleFailure(task)

        if not args.continuous:
            break
