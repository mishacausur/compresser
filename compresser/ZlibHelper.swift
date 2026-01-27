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
        
        var stream = z_stream()
        stream.zalloc = nil
        stream.zfree = nil
        stream.opaque = nil
        
        let rcInit = deflateInit_(
            &stream,
            Z_DEFAULT_COMPRESSION,
            ZLIB_VERSION,
            Int32(MemoryLayout<z_stream>.size)
        )
        
        guard rcInit == Z_OK else {
            throw NSError(domain: "zlib", code: Int(rcInit))
        }
        
        defer { deflateEnd(&stream) }
        
        var output = Data()
        let chunkSize = 64 * 1024
        var buffer = [UInt8](repeating: 0, count: chunkSize)
        
        try data.withUnsafeBytes { (inRaw: UnsafeRawBufferPointer) in
            guard let inBase = inRaw.bindMemory(to: UInt8.self).baseAddress else {
                return
            }
            stream.next_in = UnsafeMutablePointer(mutating: inBase)
            stream.avail_out = uInt(inRaw.count)
            
            while true {
                stream.next_out = &buffer
                stream.avail_out = uInt(buffer.count)
                
                let rc = deflate(&stream, Z_FINISH)
                
                let produced = buffer.count - Int(stream.avail_out)
                if produced > 0 { output.append(buffer, count: produced) }
                
                if rc == Z_STREAM_END { break }
                guard rc == Z_OK else {
                    throw NSError(domain: "zlib", code: Int(rc))
                }
            }
            
            return output
        }
    }
}
