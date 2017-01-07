//
//  String+Extension.swift
//  CustomPlayer
//
//  Created by Hayder on 2016/12/31.
//  Copyright © 2016年 Hayder. All rights reserved.
//

import UIKit

extension String{
    
    static func convertTimeWithSecond(second: TimeInterval) -> String{
        
        let date = Date(timeIntervalSince1970: second)
        let fmt = DateFormatter()
        
        if second/3600>=1 {
            
            fmt.dateFormat = "HH:mm:ss"
        }else
        {
            fmt.dateFormat = "mm:ss"
        }
        
        return fmt.string(from: date)
    }
}
