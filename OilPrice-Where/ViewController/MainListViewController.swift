//
//  ViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.

import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa
import NSObject_Rx
import TMapSDK


class MainListViewController: CommonViewController, TMapTapiDelegate {
   //Network
   var reachability: Reachability? = Reachability()
   
   //CoreLocation
   var locationManager = CLLocationManager() // locationManager
   var oldLocation: CLLocation?
   var lastLocationError: Error? // Location Error 확인
   let firebaseUtility = FirebaseUtility()
   
   //Reverse Geocoding
   let geocoder = CLGeocoder() // 지오코딩을 수행할 객체
   var performingReverseGeocoding = false // 아직 위치가 없거나 주소가 일치 하지 않을 때는 주소를 받지 않을 것이므로
   // Bool변수로 받을 지 안받을 지 선택한다.
   var lastGeocodingError: Error? // 문제가 발생 했을 때 오류 저장 변수
   var lastContentOffset: CGFloat = 0 // 테이블 뷰 스크롤의 현재 위치 저장함수
   
   // Map
   @IBOutlet weak var appleMapView: MKMapView! // 맵 뷰
   var currentCoordinate: CLLocationCoordinate2D? // 현재 좌표
   var currentPlacemark: CLPlacemark? // 주소결과가 들어있는 객체
   var annotations: [CustomMarkerAnnotation] = [] // 마커 배열 생성
   @IBOutlet weak var mapView : UIView! // 애플맵을 포함시키고 있는 뷰
   @IBOutlet weak var currentLocationButton : UIButton! // 현재 위치 표시 버튼
   @IBOutlet weak var currentLocationButtonTop: NSLayoutConstraint! // 현재 위치 Top Layout
   @IBOutlet weak var popupView : PopupView!
   var isSelectedAnnotion: Bool = false
   
   // Detail View
   @IBOutlet weak var detailView : DetailView! // Detail View
   
   // TableView
   @IBOutlet weak var tableListView : UIView! // 테이블 뷰를 포함하고 있는 뷰
   @IBOutlet weak var tableView : UITableView! // 메인리스트 테이블 뷰
   var selectIndexPath: IndexPath? // 선택된 인덱스 패스
   var oldIndexPath = IndexPath()
   var refreshControl = UIRefreshControl() // Refresh Controller
   
   // HeaderView
   @IBOutlet weak var toListButton : UIView! //
   @IBOutlet weak var toImageView : UIImageView!
   @IBOutlet weak var toLabel : UILabel!
   @IBOutlet weak var headerViewConstraint: NSLayoutConstraint!
   @IBOutlet weak var headerView: MainHeaderView!
   @IBOutlet weak var priceView: UIView!
   
   @IBOutlet weak var mainProductTitleLabel : UILabel!
   @IBOutlet weak var mainProductCostLabel : UILabel!
   @IBOutlet weak var mainProductImageView : UIImageView!
   
   @IBOutlet weak var secondProductTitleLabel : UILabel!
   @IBOutlet weak var secondProductCostLabel : UILabel!
   @IBOutlet weak var secondProductImageView : UIImageView!
   
   @IBOutlet weak var thirdProductTitleLabel : UILabel!
   @IBOutlet weak var thirdProductCostLabel : UILabel!
   @IBOutlet weak var thirdProductImageView : UIImageView!
   
   var mainListPage = true
   var tapGesture = UITapGestureRecognizer()
   var sortData: [GasStation] = []
   
   // StatusBarBackView
   @IBOutlet weak var statusBarBackView: UIView!
   
   //Etc
   let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate // 앱 델리게이트
   var lastKactecX: Double? // KatecX 좌표
   var lastKactecY: Double? // KatecY 좌표
   var selectMarker = false // 마커 선택 여부
   var lastBottomConstant: CGFloat? // 전환 버튼 애니메이션 관련 Bottom Constraint
   var priceSortButton: UIButton! // 가격 순으로 정렬 해주는 버튼
   var distanceSortButton: UIButton! // 거리 순으로 정렬 해주는 버튼
   var lastSelectedSortButton: UIButton! // 마지막 정렬
   @IBOutlet weak var noneView: UIView! // 리스트가 아무 것도 없을 때 보여주는 뷰
   @IBOutlet weak var noneLabel : UILabel! // NoneView에 보여줄 Label
   
   // 메인리스트 / 맵 일때 StatusBarStyle 설정
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return mainListPage ? .lightContent : .default
   }
   
   deinit {
      reachability = nil
      reachability?.stopNotifier()
   }
   
   override func viewDidLoad() {
      TMapApi.setSKTMapAuthenticationWithDelegate(self, apiKey: "219c2c34-cdd2-45d3-867b-e08c2ea97810")
      super.viewDidLoad()
      createSortView() // 가격순, 거리순 버튼 생성 및 설정
      setting() // 기본 설정
      setAverageCosts() // HeaderView 설정
      isDisplayNoneView()
      configureLocationServices()
      
      let target = DefaultData.shared
      
      Observable.combineLatest(target.oilSubject, target.radiusSubject, target.brandSubject)
         .subscribe(onNext: { _ in
            self.configureLocationServices()
            self.refresh()
         })
         .disposed(by: rx.disposeBag)
   }
   
   //Mark: 기본 설정 (viewDidLoad)
   // 가격순, 거리순 버튼 생성
   func createSortView() {
      let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
      
      // 가격순 버튼 설정
      self.priceSortButton = UIButton(frame: CGRect(x: 15, y: 0, width: 45, height: 30))
      self.priceSortButton.setTitle("가격순", for: .normal)
      self.priceSortButton.setTitleColor(UIColor(named: "DefaultColor"), for: .normal)
      self.priceSortButton.setTitleColor(UIColor(named: "DarkMain"), for: .selected)
      self.priceSortButton.addTarget(self, action: #selector(self.isTableViewSort(_:)), for: .touchUpInside)
      self.priceSortButton.tag = 1
      self.priceSortButton.isSelected = true
      self.priceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
      sectionHeaderView.addSubview(self.priceSortButton)
      
      // 거리순 버튼 설정
      distanceSortButton = UIButton(frame: CGRect(x: 69, y: 0, width: 45, height: 30))
      self.distanceSortButton.setTitle("거리순", for: .normal)
      self.distanceSortButton.setTitleColor(UIColor(named: "DefaultColor"), for: .normal)
      self.distanceSortButton.setTitleColor(UIColor(named: "DarkMain"), for: .selected)
      self.distanceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundR", size: 16)
      self.distanceSortButton.addTarget(self, action: #selector(self.isTableViewSort(_:)), for: .touchUpInside)
      self.distanceSortButton.tag = 2
      sectionHeaderView.addSubview(distanceSortButton)
      
      // 기본 설정 버튼(가격순)
      lastSelectedSortButton = priceSortButton
      
      tableView.addSubview(sectionHeaderView)
   }
   
   // 기본 세팅
   func setting() {
      do {
         try reachability?.startNotifier()
      } catch {
         print(error.localizedDescription)
      }
      
      reachability?.whenReachable = { _ in // 네트워크 연결 시 로케이션 서비스 시작
         self.configureLocationServices()
         self.refresh()
      }
      
      reachability?.whenUnreachable = { _ in // 네트워크 연결 시 로케이션 서비스 시작
         Preferences.notConnect()
         DefaultData.shared.stationsSubject.onNext([])
         self.reset()
         self.sortData = []
         self.isDisplayNoneView()
         self.tableView.reloadData()
      }
      
      self.noneLabel.font = UIFont(name: "NanumSquareRoundB", size: 17) //NoneView 내의 NoneLabel 설정
      priceView.layer.cornerRadius = 10
      
      // currentLocationButton 설정
      currentLocationButton.layer.cornerRadius = self.currentLocationButton.bounds.height / 2
      currentLocationButton.clipsToBounds = false
      currentLocationButton.layer.shadowColor = UIColor.black.cgColor
      currentLocationButton.layer.shadowOpacity = 0.3
      currentLocationButton.layer.shadowOffset = CGSize(width: 1, height: 1)
      currentLocationButton.layer.shadowRadius = 1.5
      currentLocationButton.addTarget(self, action: #selector(self.currentLoaction(_:)), for: .touchUpInside)
      
      // Draw a shadow
      currentLocationButton.layer.shadowPath = UIBezierPath(roundedRect: currentLocationButton.bounds,
                                                            cornerRadius: self.currentLocationButton.bounds.height / 2).cgPath
      
      // popupView 설정
      popupView.layer.cornerRadius = 7
      popupView.clipsToBounds = true
      popupView.layer.shadowColor = UIColor.black.cgColor
      popupView.layer.shadowOpacity = 0.3
      popupView.layer.shadowOffset = CGSize(width: 1, height: 1)
      popupView.layer.shadowRadius = 1.5
      
      // Draw a shadow
      popupView.layer.shadowPath = UIBezierPath(roundedRect: currentLocationButton.bounds,
                                                cornerRadius: 10).cgPath
      
      appDelegate.mainViewController = self
      
      // 전환 버튼 설정
      self.toListButton.layer.cornerRadius = self.toListButton.bounds.height / 2
      self.toImageView.image = toImageView.image!.withRenderingMode(.alwaysTemplate)
      self.toImageView.tintColor = UIColor.white
      // 전환 버튼 그림자 설정
      toListButton.clipsToBounds = false
      toListButton.layer.shadowColor = UIColor.black.cgColor
      toListButton.layer.shadowOpacity = 0.5
      toListButton.layer.shadowOffset = CGSize(width: 1, height: 1)
      toListButton.layer.shadowRadius = 2
      
      // Draw a shadow
      toListButton.layer.shadowPath = UIBezierPath(roundedRect: toListButton.bounds, cornerRadius: self.toListButton.bounds.height / 2).cgPath
      
      let tap = UITapGestureRecognizer(target: self, action: #selector(self.toList(_:)))
      toListButton.addGestureRecognizer(tap)
      
      // 테이블 뷰 헤더 경계 값 설정
      self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      
      // 테이블뷰내에 Refresh 설정
      self.refreshControl.addTarget(self,
                                    action: #selector(refresh),
                                    for: UIControlEvents.valueChanged)
      if #available(iOS 10.0, *) { // iOS 버전 별 설정
         tableView.refreshControl = self.refreshControl
      }
      
      // 현재 위치 버튼 기종별 설정
      if UIDevice.current.isiPhoneX {
         currentLocationButtonTop.constant = 55
      } else {
         currentLocationButtonTop.constant = 35
      }
   }
   
   func reset() {
      appleMapView.removeAnnotations(annotations)
      annotations = []
      selectIndexPath = nil
   }
   
   func gasStationListData(katecPoint: KatecPoint) {
      guard let radius = try? DefaultData.shared.radiusSubject.value(),
         let oilSubject = try? DefaultData.shared.oilSubject.value() else { return }
      let brand = try? DefaultData.shared.brandSubject.value()
      
      ServiceList.gasStationList(x: katecPoint.x,
                                 y: katecPoint.y,
                                 radius: radius,
                                 prodcd: oilSubject,
                                 sort: 1,
                                 appKey: Preferences.getAppKey()) { (result) in
                                    
                                    switch result {
                                    case .success(let gasStationData):
                                       print("DataLoad")
                                       
                                       var target = gasStationData.result.gasStations
                                       
                                       if brand != "ALL" {
                                          target = target.filter { $0.brand == brand ?? "" }
                                       }
                                       
                                       DefaultData.shared.stationsSubject.onNext(target)
                                       
                                       self.sortData = target.sorted(by: {$0.distance < $1.distance})
                                       self.popupView.configure()
                                       self.showMarker()
                                       self.refreshControl.endRefreshing()
                                       self.tableView.reloadData()
                                       self.isDisplayNoneView()
                                    case .error(let error):
                                       print(error)
                                    }
      }
   }
   
   func isDisplayNoneView() {
      DefaultData.shared.stationsSubject
         .map { !$0.isEmpty }
         .bind(to: noneView.rx.isHidden)
         .disposed(by: rx.disposeBag)
   }
   
   //Mark: Display 관련 설정
   // Reload
   @objc func refresh() {
      oldLocation = nil
      reset()
      configureLocationServices()
   }
   
   // TableView List Sort Func(가격, 거리)
   @objc func isTableViewSort(_ sender: UIButton) {
      guard lastSelectedSortButton.tag != sender.tag else {
         return
      }
      
      if sender.tag == priceSortButton.tag { // Sender와 priceButton과 같을 시에 가격순 정렬
         priceSortButton.isSelected = true
         priceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
         distanceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundR", size: 16)
         distanceSortButton.isSelected = false
         
         lastSelectedSortButton = priceSortButton
      } else { // 거리순 정렬
         distanceSortButton.isSelected = true
         distanceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
         priceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundR", size: 16)
         priceSortButton.isSelected = false
         
         lastSelectedSortButton = distanceSortButton
      }
      selectIndexPath = nil
      appleMapView.removeAnnotations(annotations)
      annotations = []
      showMarker()
      tableView.reloadData()
   }
   
   // 전환 액션
   @objc func toList(_ sender: UIView) {
      if mainListPage { // 메인리스트 페이지 일시 맵뷰로 전환
         self.view.sendSubview(toBack: self.tableListView)
         
         // 전환 버튼 애니메이션 관련
         if lastBottomConstant == 10 {
            if let indexPath = selectIndexPath {
               let cell = tableView.cellForRow(at: indexPath) as! GasStationCell
               if cell.stationView.id == detailView.id {
                  if detailView.favoriteButton.isSelected != cell.stationView.favoriteButton.isSelected {
                     self.detailView.clickedEvent(detailView.favoriteButton)
                  }
               }
               self.detailView.detailViewBottomConstraint.constant = 10
               UIView.animate(withDuration: 0.3) {
                  self.view.layoutIfNeeded()
               }
            } else if oldIndexPath != IndexPath() && isSelectedAnnotion {
               let cell = tableView.cellForRow(at: oldIndexPath) as! GasStationCell
               if cell.stationView.id == detailView.id {
                  if detailView.favoriteButton.isSelected != cell.stationView.favoriteButton.isSelected {
                     self.detailView.clickedEvent(detailView.favoriteButton)
                  }
               }
               self.detailView.detailViewBottomConstraint.constant = 10
               UIView.animate(withDuration: 0.3) {
                  self.view.layoutIfNeeded()
               }
            }
         } else {
            self.detailView.detailViewBottomConstraint.constant = -150
            UIView.animate(withDuration: 0.3) {
               self.view.layoutIfNeeded()
            }
         }
         
         toLabel.text = "목록"
         toImageView.image = UIImage(named: "listButton")
         statusBarBackView.isHidden = true
         mainListPage = false
      } else {
         self.view.sendSubview(toBack: self.mapView)
         toImageView.image = UIImage(named: "mapButton")
         toLabel.text = "지도"
         lastBottomConstant = self.detailView.detailViewBottomConstraint.constant
         self.detailView.detailViewBottomConstraint.constant = -150
         UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
         }
         statusBarBackView.isHidden = false
         mainListPage = true
      }
      tableView.reloadData()
   }
   
   // 길안내 시작
   @objc func navigateStart(_ sender: UITapGestureRecognizer) {
      guard let katecX = lastKactecX?.roundTo(places: 0),
         let katecY = lastKactecY?.roundTo(places: 0),
         let navi = try? DefaultData.shared.naviSubject.value(),
         let type = NaviType(rawValue: navi) else { return }
      
      switch type {
      case .tMap:
         let coordinator = Converter.convertKatecToWGS(katec: KatecPoint(x: katecX, y: katecY))
         print("TAP", TMapApi.isTmapApplicationInstalled())
         
         if TMapApi.isTmapApplicationInstalled() {
            let _ = TMapApi.invokeRoute(detailView.stationName.text!, coordinate: coordinator)
         } else {
            let alert = UIAlertController(title: "T Map이 없습니다.",
                                          message: "다운로드 페이지로 이동하시겠습니까?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { (_) in
                                          guard let url = URL(string: TMapApi.getTMapDownUrl()) else {
                                             return
                                          }
                                          
                                          if UIApplication.shared.canOpenURL(url) {
                                             UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                          }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
         }
      case .kakao:
         let destination = KNVLocation(name: detailView.stationName.text!,
                                       x: NSNumber(value: katecX),
                                       y: NSNumber(value: katecY))
         let options = KNVOptions()
         options.routeInfo = false
         let params = KNVParams(destination: destination,
                                options: options)
         KNVNaviLauncher.shared().navigate(with: params) { (error) in
            self.handleError(error: error)
         }
      }
   }
   
   // 길안내 에러 발생
   func handleError(error: Error?) {
      if let error = error as NSError? {
         print(error)
         let alert = UIAlertController(title: self.title!,
                                       message: error.localizedFailureReason,
                                       preferredStyle: UIAlertControllerStyle.alert)
         alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel,
                                       handler: nil))
         self.present(alert, animated: true, completion: nil)
      }
   }
}
