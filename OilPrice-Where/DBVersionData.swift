//
//  DBVersionData.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/19.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation

class DbVersionData: NSObject {
    
    var lastest_version_code: String        /** 최신버전 코드     */
    var lastest_version_name: String        /** 최신버전 명      */
    var minimum_version_code: String        /** 최소버전 코드     */
    var minimum_version_name: String        /** 최소버전 명      */
    
    
    init(lastest_version_code: String, lastest_version_name: String,
         minimum_version_code: String, minimum_version_name: String) {
        
        self.lastest_version_code       = lastest_version_code
        self.lastest_version_name       = lastest_version_name
        self.minimum_version_code       = minimum_version_code
        self.minimum_version_name       = minimum_version_name
    }
    
    convenience override init() {
        self.init(lastest_version_code: "", lastest_version_name: "",
                  minimum_version_code: "", minimum_version_name: "")
    }
}
