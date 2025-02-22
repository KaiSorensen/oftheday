import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var userModel: OTDUserModel
    @State private var selectedTab: Int = 1
    @State private var showLogin: Bool = false
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SearchView(userModel: userModel)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(0)
            TodayView(userModel: userModel)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Today")
                }
                .tag(1)
            ListManagementView(userModel: userModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Lists")
                }
                .tag(2)
        }
        .onAppear {
            // If no user is logged in, present the LoginView.
            if userModel.currentUser == nil {
                showLogin = true
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView(userModel: _userModel, showLogin: $showLogin)
        }
//        .onReceive(NotificationCenter.default.publisher(for: .didReceiveOTDNotification)) { notif in
//            guard let userInfo = notif.userInfo,
//                  let listUUID = userInfo["listUUID"] as? UUID,
//                  let itemUUID = userInfo["itemUUID"] as? UUID else {
//                      return
//                  }
//            listsModel.openListItem(listUUID: listUUID, itemUUID: itemUUID)
//            selectedTab = 2
//        }
    }
}
