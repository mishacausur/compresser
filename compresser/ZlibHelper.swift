//
//  ZlibHelper.swift
//  compresser
//
//  Created by Misha Causur on 26.01.2026.
//

import Foundation
import zlib

final class ZlibHelper {
    func compress(_ data: Data) throws -> Data {
        guard !data.isEmpty else {
            return Data()
        }
        return Data()
    }
}
