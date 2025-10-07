import type { SiftNone } from "./Util"

import SiftArray from "./Array"
import SiftDictionary from "./Dictionary"
import SiftSet from "./Set"

declare namespace Sift {
  export const None: SiftNone
  export type None = SiftNone

  export {
    SiftArray as Array,
    SiftArray as List,
    SiftDictionary as Dictionary,
    SiftSet as Set,
  }
}

export = Sift
