//
//  API.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 25..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

private let baseURL = "http://www.opinet.co.kr/api"

// API Protocol
protocol APIProtocol
{
    var urlString: String { get }
}

enum API: APIProtocol {
    // ======= API 사용법 =======
    // LIST를 API URL 열거형으로 정의
    // 참조) String format에 아규먼트 값을 넣을 경우 필요한 형식
    // %d = Int, %ld = Double, %f = Float, %@ = String
    // %.4f 는 Float의 소숫점 4자리까지만 표기함, 참고로 API에 사용되는 위도 경도 값은 소숫점 6자리 까지
    // %03 는 000, 001, 002 로 형 변환하며, %02는 01, 02, 03 로 형 변환
    // ======= API 내부 파라미터 =======
    // prodcd = 휘발유:B027, 경유:D047, 고급휘발유: B034, C004:실내등유, 자동차부탄: K015 (미입력시 모든 제품)
    // area = 지역구분 (미입력시 전국, 시도코드(2자리):해당시도 기준, 시군코드(4자리):해당시군 기준)
    // x,y = 기준 위치 X,Y좌표 (KATEC)
    // radius = 반경 선택 ( 최대 5000, 단위 :m)
    // sort = 1: 가격순, 2: 거리순
    // osnm = 상호 검색명 (검색어 두글자 이상)
    enum LIST: String {
        // 전국 주유소 평균 가격
        case avgAll = "/avgAllPrice.do?out=json&code=F302180619"
        // 시도별 주유소 평균 가격
        case avgSido = "/avgSidoPrice.do?prodcd=%@&sido=%02d&out=json&code=F302180619"
        // 시군구별 주유소 평균 가격
        case avgSigun = "/avgSigunPrice.do?prodcd=%@&sigun=%04d&sido=%02d&out=json&code=F302180619"
        // 최근 7일간 전국 일일 평균 가격
        case avgRecent = "/avgRecentPrice.do?prodcd=%@&out=json&code=F302180619"
        // 최근 1주의 주간 평균 유가(전국/시도별)
        case avgLastWeek = "/avgLastWeek.do?prodcd=%@&code=F302180619&out=json"
        // 지역별 최저가 주유소(Top10)
        case lowTop10 = "/lowTop10.do?area=%04d&prodcd=%@&out=json&code=F302180619"
        // 반경내 주유소 검색
        case aroundAll = "/aroundAll.do?x=%.5f&y=%.5f&radius=%d&prodcd=%@&sort=%d&out=json&code=F302180619"
        // 주유소 상세 정보
        case detailById = "/detailById.do?code=F302180619&id=%@&out=json"
        // 지역 코드
        case areaCode = "/areaCode.do?out=json&code=F302180619&area=%@"
        // 상호로 주유소 검색
        case searchByName = "/searchByName.do?code=F302180619&out=json&osnm=%@"
    }
    
    // API List
    case avgAll // 전국 주유소 평균 가격
    case avgSido(prodcd: String, sido: Int) // 시도별 주유소 평균 가격
    case avgSigun(prodcd: String, sigun: Int, sido: Int) // 시군구별 주유소 평균 가격
    case avgRecent(prodcd: String) // 최근 7일간 전국 일일 평균 가격
    case avgLastWeek(prodcd: String) // 최근 1주의 주간 평균 유가(전국/시도별)
    case lowTop10(prodcd: String, area: String) // 지역별 최저가 주유소(Top10)
    case aroundAll(x: Double, y: Double, radius: Int, prodcd: String, sort: Int) // 반경내 주유소 검색
    case detailById(id: String) // 주유소 상세 정보
    case areaCode(area: String) // 지역 코드
    case searchByName(osnm: String) // 상호로 주유소 검색
    
    // endPoint에 파라미터 값을 반환하는 변수
    private var endpointString: String {
        get {
            var tempString: String = ""
            switch self {
            case .avgAll:
                tempString = String(format: LIST.avgAll.rawValue)
            case .avgSido(let prodcd, let sido):
                tempString = String(format: LIST.avgSido.rawValue, prodcd, sido)
            case .avgSigun(let prodcd, let sigun, let sido):
                tempString = String(format: LIST.avgSigun.rawValue, prodcd, sigun, sido)
            case .avgRecent(let prodcd):
                tempString = String(format: LIST.avgRecent.rawValue, prodcd)
            case .avgLastWeek(let prodcd):
                tempString =  String(format: LIST.avgLastWeek.rawValue, prodcd)
            case .lowTop10(let prodcd, let area):
                tempString = String(format: LIST.lowTop10.rawValue, prodcd, area)
            case .aroundAll(let x, let y, let radius, let prodcd, let sort):
                tempString = String(format: LIST.aroundAll.rawValue, x, y, radius, prodcd, sort)
            case .detailById(let id):
                tempString = String(format: LIST.detailById.rawValue, id)
            case .areaCode(let area):
                tempString = String(format: LIST.areaCode.rawValue, area)
            case .searchByName(let osnm):
                tempString = String(format: LIST.searchByName.rawValue, osnm)
            }
            return tempString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
    }
    
    // 기본 URL 주소와 Endpoint를 합쳐주는 변수
    var urlString: String {
        get {
            return baseURL + self.endpointString
        }
    }
}
