//
//  SubtitleConverter.swift
//  VODPlayground
//
//  Created by Yousef on 9/14/21.
//

import Foundation

class Subtitle {
    
    /// Subtitle parser
    /// it takes the content of srt file & convert it into vtt format  then creat phisical  file in the cache folder then return URL for the created file
    /// it is failable so it may or may not succeed to create that file, that is why it returns optional URL
    ///
    /// ```
    ///  let content = try! String(contentsOf: url, encoding: .utf8)
    ///  guard let url = convertIntoVtt(content) else { return }
    /// ```
    ///
    /// - Parameter payload: the content of srt file
    /// - Returns: optinal URL for subtitles file of type vtt
    static func convertIntoVtt(_ payload: String) -> URL? {
        var string = "WEBVTT" + "\r\n" + "\r\n"
        
        do {
            
            // Prepare payload
            var payload = payload.replacingOccurrences(of: "\n\r\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\n\n\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\r\n", with: "\n")
            
            
            // Get groups
            let regexStr = "(\\d+)\\n([\\d:,.]+)\\s+-{2}\\>\\s+([\\d:,.]+)\\n([\\s\\S]*?(?=\\n{2,}|$))"
            let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
            let matches = regex.matches(in: payload, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, payload.count))
            for m in matches {
                
                let group = (payload as NSString).substring(with: m.range)
                
                // Get index
                var regex = try NSRegularExpression(pattern: "^[0-9]+", options: .caseInsensitive)
                var match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                
                // Get "from" & "to" time
                regex = try NSRegularExpression(pattern: "\\d{1,2}:\\d{1,2}:\\d{1,2}[,.]\\d{1,3}", options: .caseInsensitive)
                match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                guard match.count == 2 else {
                    continue
                }
                guard let from = match.first, let to = match.last else {
                    continue
                }
                
                
                let fromTotalStr = (group as NSString).substring(with: from.range)
                
                let toTotalStr = (group as NSString).substring(with: to.range)
                
                var fromStr = String((fromTotalStr.split(separator: ","))[0])
                if fromStr == "00:00:00" {
                    fromStr = "00:00:01"
                }

                var toStr = String((toTotalStr.split(separator: ","))[0])
                if toStr == "00:00:00" {
                    toStr = "00:00:01"
                }
                
                string = string + fromStr + " --> " + toStr + "\r\n"
                
                // Get text & check if empty
                let range = NSMakeRange(0, to.range.location + to.range.length + 1)
                guard (group as NSString).length - range.length > 0 else {
                    continue
                }
                let text = (group as NSString).replacingCharacters(in: range, with: "")
                string = string + text + "\r\n\r\n"
            }
            let url = createFile(string: string)
            return url
            
        } catch {
            
            return nil
            
        }
        
    }
    
    
    /// create phisical file on the devide with guid name and vtt type in the cache folder
    /// it is failable thats why it may or may not return url
    /// - Parameter string: content of vtt file
    /// - Returns: optional URL for the file
    private static func createFile(string: String) -> URL? {
        let fileName = NSUUID().uuidString + ".vtt"
        let url = getCachesDirectory().appendingPathComponent(fileName)
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
    
    
    /// return  the path of the cache folder in the device
    /// - Returns: URL for the cache folder
    static func getCachesDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    
    /// Subtitle parser
    /// it takes the content of srt file & convert it into dictionary which can be used later to show subtites with video
    ///
    /// ```
    ///  let content = try! String(contentsOf: url, encoding: .utf8)
    ///  let dict = parseDict(content) else
    /// ```
    ///
    /// - Parameter payload: the content of srt file
    /// - Returns: dictionary hold the subtitles as text
    static func parseDict(_ payload: String) -> NSDictionary {
        do {
            
            // Prepare payload
            var payload = payload.replacingOccurrences(of: "\n\r\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\n\n\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\r\n", with: "\n")
            
            // Parsed dict
            let parsed = NSMutableDictionary()
            
            // Get groups
            let regexStr = "(\\d+)\\n([\\d:,.]+)\\s+-{2}\\>\\s+([\\d:,.]+)\\n([\\s\\S]*?(?=\\n{2,}|$))"
            let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
            let matches = regex.matches(in: payload, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, payload.count))
            for m in matches {
                
                let group = (payload as NSString).substring(with: m.range)
                
                // Get index
                var regex = try NSRegularExpression(pattern: "^[0-9]+", options: .caseInsensitive)
                var match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                guard let i = match.first else {
                    continue
                }
                let index = (group as NSString).substring(with: i.range)
                
                // Get "from" & "to" time
                regex = try NSRegularExpression(pattern: "\\d{1,2}:\\d{1,2}:\\d{1,2}[,.]\\d{1,3}", options: .caseInsensitive)
                match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                guard match.count == 2 else {
                    continue
                }
                guard let from = match.first, let to = match.last else {
                    continue
                }
                
                var h: TimeInterval = 0.0, m: TimeInterval = 0.0, s: TimeInterval = 0.0, c: TimeInterval = 0.0
                
                let fromTotalStr = (group as NSString).substring(with: from.range)
                var scanner = Scanner(string: fromTotalStr)
                h = scanner.scanDouble() ?? 0
                _ = scanner.scanString(":")
                m = scanner.scanDouble() ?? 0
                _ = scanner.scanString(":")
                s = scanner.scanDouble() ?? 0
                _ = scanner.scanString(",")
                c = scanner.scanDouble() ?? 0
                let fromTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
                
                let toTotalStr = (group as NSString).substring(with: to.range)
                scanner = Scanner(string: toTotalStr)
                h = scanner.scanDouble() ?? 0
                _ = scanner.scanString(":")
                m = scanner.scanDouble() ?? 0
                _ = scanner.scanString(":")
                s = scanner.scanDouble() ?? 0
                _ = scanner.scanString(",")
                c = scanner.scanDouble() ?? 0
                let toTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
                
//                let fromStr = fromTotalStr.replacingOccurrences(of: ",", with: ":")
//                let toStr = toTotalStr.replacingOccurrences(of: ",", with: ":")
                
                var fromStr = String((fromTotalStr.split(separator: ","))[0])
                if fromStr == "00:00:00" {
                    fromStr = "00:00:01"
                }

                var toStr = String((toTotalStr.split(separator: ","))[0])
                if toStr == "00:00:00" {
                    toStr = "00:00:01"
                }
                
                // Get text & check if empty
                let range = NSMakeRange(0, to.range.location + to.range.length + 1)
                guard (group as NSString).length - range.length > 0 else {
                    continue
                }
                let text = (group as NSString).replacingCharacters(in: range, with: "")
                // Create final object
                let final = NSMutableDictionary()
                final["from"] = fromTime
                final["to"] = toTime
                final["text"] = text
                parsed[index] = final
                
            }
            return parsed
            
        } catch {
            
            return NSDictionary()
            
        }
        
    }
    
    /// Search for subtitle on time
    ///
    /// - Parameters:
    ///   - payload: the dictionary which holds the hole subtitles
    ///   - time: exact time of player
    /// - Returns: subtitle
    static func searchSubtitles(_ payload: NSDictionary?, _ time: TimeInterval) -> String? {
        let predicate = NSPredicate(format: "(%f >= %K) AND (%f <= %K)", time, "from", time, "to")
        
        guard let values = payload?.allValues, let subtitles = (values as NSArray).filtered(using: predicate) as? [NSDictionary] else {
            return nil
        }
        
        var text: [String] = []
        if subtitles.count > 0 {
        for item in subtitles {
            if let subtitle = item.value(forKey: "text") as? String  {
                text.append(subtitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            }
        }
            return text.joined(separator: "\r\n")
        } else {
            return nil
        }
    }
    
}
