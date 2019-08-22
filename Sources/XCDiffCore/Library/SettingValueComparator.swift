//
// Copyright 2019 Bloomberg Finance L.P.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

class SettingValueComparator: ValueComparator {
    typealias T = String

    private let projectNameDifference: String?

    // MARK: - Lifecycle

    init(firstProjectName: String?, secondProjectName: String?) {
        guard let firstProjectName = firstProjectName, let secondProjectName = secondProjectName else {
            projectNameDifference = nil
            return
        }

        projectNameDifference = SettingValueComparator.difference(firstProjectName, secondProjectName)
    }

    // MARK: - ValueComparator

    func compare(_ lha: String, _ rha: String) -> ComparisonResult {
        if equal(lha, rha) {
            return .orderedSame
        }
        if lha < rha {
            return .orderedAscending
        }
        return .orderedDescending
    }

    // MARK: - Private

    private func equal(_ lha: String, _ rha: String) -> Bool {
        guard lha != rha else {
            return true
        }
        guard let projectNameDifference = projectNameDifference else {
            return lha == rha
        }
        let settingValuesDifference = SettingValueComparator.difference(lha, rha)
        return projectNameDifference == settingValuesDifference
    }

    func removeMultipleOccurences(of token: String, in value: String) -> String {
        guard let firstSubstringRange = value.range(of: token) else {
            return value
        }

        return value.replacingOccurrences(of: token,
                                          with: "",
                                          options: [],
                                          range: firstSubstringRange.upperBound ..< value.endIndex)
    }

    private static func difference(_ lha: String, _ rha: String) -> String {
        let longVal, shortVal: String
        if lha.count > rha.count {
            longVal = lha
            shortVal = rha
        } else {
            longVal = rha
            shortVal = lha
        }

        var longIndex = longVal.startIndex, shortIndex = shortVal.startIndex
        var diff = ""
        while longIndex < longVal.endIndex, shortIndex < shortVal.endIndex {
            if longVal[longIndex] == shortVal[shortIndex] {
                shortIndex = shortVal.index(after: shortIndex)
                longIndex = longVal.index(after: longIndex)
            } else {
                diff.append(longVal[longIndex])
                longIndex = longVal.index(after: longIndex)
            }
        }

        while longIndex < longVal.endIndex {
            diff.append(longVal[longIndex])
            longIndex = longVal.index(after: longIndex)
        }

        while shortIndex < shortVal.endIndex {
            diff.append(shortVal[shortIndex])
            shortIndex = shortVal.index(after: shortIndex)
        }

        return diff
    }
}
