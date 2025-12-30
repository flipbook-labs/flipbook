import React from "react";
import styles from "./styles.module.css";

enum ReviewStatus {
	Drafting,
	Rejected,
	Approved,
}

enum ImplementationStatus {
	NotStarted,
	InProgress,
	WontDo,
	Done,
}

interface ProposalFrontmatter {
	approval?: ReviewStatus;
	status?: ImplementationStatus;
}

interface ProposalMetaProps {
	frontMatter?: ProposalFrontmatter;
}

export default function ProposalMeta({
	frontMatter,
}: ProposalMetaProps): JSX.Element {
	const { approval, status } = frontMatter;

	const getReviewStatusStyle = (approval: ReviewStatus) => {
		switch (approval) {
			case ReviewStatus.Drafting:
				return styles.drafting;
			case ReviewStatus.Approved:
				return styles.approved;
			case ReviewStatus.Rejected:
				return styles.rejected;
		}
	};

	const getImplementationStatusStyle = (status: ImplementationStatus) => {
		switch (status) {
			case ImplementationStatus.NotStarted:
				return styles.statusPlanned;
			case ImplementationStatus.InProgress:
				return styles.statusInProgress;
			case ImplementationStatus.WontDo:
				return styles.rejected;
			case ImplementationStatus.Done:
				return styles.statusCompleted;
		}
	};

	return (
		<table className={styles.proposalMeta}>
			<tbody>
				{approval && (
					<tr className={styles.metaRow}>
						<td className={styles.metaLabel}>Review Status</td>
						<td className={styles.metaValue}>
							<span
								className={`${styles.badge} ${getReviewStatusStyle(approval)}`}
							>
								{approval}
							</span>
						</td>
					</tr>
				)}
				{status && (
					<tr className={styles.metaRow}>
						<td className={styles.metaLabel}>Status</td>
						<td className={styles.metaValue}>
							<span
								className={`${styles.badge} ${getImplementationStatusStyle(
									status
								)}`}
							>
								{status}
							</span>
						</td>
					</tr>
				)}
			</tbody>
		</table>
	);
}
