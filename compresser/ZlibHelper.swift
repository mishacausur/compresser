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
            guard let inBase = inRaw.bindMemory(to: UInt8.self).baseAddress
            else {
                return
            }
            stream.next_in = UnsafeMutablePointer(mutating: inBase)
            stream.avail_in = uInt(inRaw.count)

            while true {
                var didFinish = false
                var threw: Error? = nil

                let bufferCount = buffer.count
                buffer.withUnsafeMutableBytes { outRaw in
                    guard
                        let outBase = outRaw.bindMemory(to: UInt8.self)
                            .baseAddress
                    else { return }

                    stream.next_out = outBase
                    stream.avail_out = uInt(bufferCount)

                    let rc = deflate(&stream, Z_FINISH)

                    let produced = bufferCount - Int(stream.avail_out)
                    if produced > 0 {
                        output.append(outBase, count: produced)
                    }

                    if rc == Z_STREAM_END {
                        didFinish = true
                    } else if rc != Z_OK {
                        threw = NSError(domain: "zlib", code: Int(rc))
                    }
                }

                if let threw { throw threw }
                if didFinish { break }
            }
        }
        return output
    }

    func decompress(_ data: Data) throws -> Data {
        guard !data.isEmpty else {
            return Data()
        }

        var stream = z_stream()
        stream.zalloc = nil
        stream.zfree = nil
        stream.opaque = nil

        let rcInit = inflateInit_(
            &stream,
            ZLIB_VERSION,
            Int32(MemoryLayout<z_stream>.size)
        )
        guard rcInit == Z_OK else {
            throw NSError(domain: "zlib", code: Int(rcInit))
        }
        defer { inflateEnd(&stream) }

        var output = Data()
        let chunkSize = 64 * 1024
        var buffer = [UInt8](repeating: 0, count: chunkSize)

        try data.withUnsafeBytes { (inRaw: UnsafeRawBufferPointer) in
            guard let inBase = inRaw.bindMemory(to: UInt8.self).baseAddress else {
                return
            }

            stream.next_in = UnsafeMutablePointer<UInt8>(mutating: inBase)
            stream.avail_in = uInt(inRaw.count)

            while true {
                var didFinish = false
                var threw: Error? = nil

                let bufferCount = buffer.count

                buffer.withUnsafeMutableBytes { outRaw in
                    guard
                        let outBase = outRaw.bindMemory(to: UInt8.self)
                            .baseAddress
                    else {
                        return
                    }

                    stream.next_out = outBase
                    stream.avail_out = uInt(bufferCount)

                    let rc = inflate(&stream, Z_NO_FLUSH)

                    let produced = bufferCount - Int(stream.avail_out)
                    if produced > 0 {
                        output.append(outBase, count: produced)
                    }

                    if rc == Z_STREAM_END {
                        didFinish = true
                    } else if rc != Z_OK {
                        threw = NSError(domain: "zlib", code: Int(rc))
                    }
                }

                if let threw { throw threw }
                if didFinish { break }

                if stream.avail_in == 0 {
                    throw NSError(domain: "zlib", code: Int(Z_DATA_ERROR))
                }
            }
        }
        return output
    }
}
