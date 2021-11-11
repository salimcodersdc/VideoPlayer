//
//  CodersSubtitleConverter.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/4/21.
//

import Foundation
let newLine = "\r\n"
struct srtLine: Encodable {
    let index: String
    let start: String
    let end: String
    let text: String
    
    var description: String {
        return """
            \(start) --> \(end)
            \(text)
            \(newLine)
            """
    }
}

class CodersSubtitleConverter: NSObject {
    private var lines = [srtLine]()
   
    func srtToVtt(srtFileURL: String) -> URL? {
        decodeFile(srtFileURL: srtFileURL)
        let url = createFile()
        return url
    }
    
    func decodeFile(srtFileURL: String) {
       

        guard let fileUrl = URL(string: srtFileURL) else { return }
        
        let string = try! String.init(contentsOf: fileUrl, encoding: .utf8)
        
        let scanner = Scanner(string: string)
        
        while !scanner.isAtEnd {
            autoreleasepool {
                
                let indexString: String = scanner.scanUpToCharacters(from: .newlines)!
                
                var startString = scanner.scanUpToString(" --> ")!
                startString = startString.replacingOccurrences(of: ",", with: ".")
                
                let _ = scanner.scanUpToString("-->")
                
                var endString = scanner.scanUpToCharacters(from: .newlines)!
                endString = endString.replacingOccurrences(of: "--> ", with: "")
                endString = endString.replacingOccurrences(of: ",", with: ".")
                
                var textString = scanner.scanUpToString("\r\n\r\n")!
                
                textString = textString.trimmingCharacters(in: .whitespaces)
                
                let line = srtLine(index: indexString, start: startString, end: endString, text: textString)
                lines.append(line)
                
            }
        }
    }
    
    func createFile() -> URL? {
        let fileName = NSUUID().uuidString + ".vtt"
        
        var string = "WEBVTT" + "\r\n" + "\r\n"
        for line in lines {
            string = string + line.description
        }
        
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        print("***************************************************")
        print(url.absoluteURL)
        do {
            try string.write(to: url, atomically: false, encoding: .utf8)
            return url
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    
    
    
    func readResolutions() -> [Quality]? {
        let lines = readResolutionsLines()
        let resolutions = decodeResolutions(lines: lines)
        return resolutions
    }
    
    func decodeResolutions(lines: [tmpRes]) -> [Quality]? {
        var resolutions = [Quality]()
        if lines.count == 0 { return nil }
        for line in lines {
            let qty = decodeResLine(line: line)
            resolutions.append(qty)
        }
        return resolutions
    }
    
    func decodeResLine(line: tmpRes) -> Quality {
      
        
        let values: [String] = [
            "#EXT-X-STREAM-INF:AVERAGE-BANDWIDTH=",
            "BANDWIDTH=",
            "CODECS=",
            "temp",
            "RESOLUTION="
        ]
        
        var result = [String]()
        
        let components = line.details.components(separatedBy: ",")
        
        for (index, value) in values.enumerated() {
            var aa = components[index]
            aa = aa.replacingOccurrences(of: value, with: "")
            aa = aa.replacingOccurrences(of: "\"", with: "")
            result.append(aa)
        }
        
        let quality = Quality(avBandwidth: result[0], bandWidth: result[1], codecs: result[2], resolution: result[4], URI: line.uri)
        return quality
        
    }
    
    struct tmpRes {
        let details: String
        let uri: String
    }
    
    func readResolutionsLines() -> [tmpRes] {
        
        var result = [tmpRes]()
        guard let m3uPath = Bundle.main.path(forResource: "master", ofType: "m3u8") else { return result }
        let m3uURL = URL(fileURLWithPath: m3uPath)
        
        let string = try! String.init(contentsOf: m3uURL, encoding: .utf8)

        let target = "#EXT-X-STREAM-INF:"
        let scanner = Scanner(string: string)
        
        while !scanner.isAtEnd {
            autoreleasepool {
                
                let _ = scanner.scanUpToString(target)
                let detailsString = scanner.scanUpToCharacters(from: .newlines)
            
                let uriString = scanner.scanUpToCharacters(from: .newlines)
                if let det = detailsString, let uri = uriString {
                    let tmp = tmpRes(details: det, uri: uri)
                    result.append(tmp)
                }
            }
        }
        
        return result
    }
    
}

struct Quality {
    
    let avBandwidth: String
    let bandWidth: String
    let codecs: String
    let resolution: String
    let URI: String
}
 
