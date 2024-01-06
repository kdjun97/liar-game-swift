//
//  HomeView.swift
//  LiarGame
//
//  Created by 김동준 on 12/31/23
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var liarPath = LiarPath()
    
    var body: some View {
        NavigationStack(path: $liarPath.paths) {
            HomeContentView(
                liarPath: liarPath,
                homeViewModel: homeViewModel
            )
                .navigationDestination(
                    for: PathDestination.self,
                    destination: { pathDestination in
                        switch(pathDestination) {
                        case .createRoom:
                            CreateRoomView()
                                .navigationBarBackButtonHidden(true)
                                .environmentObject(liarPath)
                        case .connectRoom:
                            ConnectRoomView()
                                .navigationBarBackButtonHidden(true)
                                .environmentObject(liarPath)
                        case .chatRoom:
                            ChatRoomView()
                                .navigationBarBackButtonHidden(true)
                                .environmentObject(liarPath)
                        }
                    }
                )
                .sheet(isPresented: $homeViewModel.isGameRuleSheetPresented) {
                    GameRuleView()
                        .presentationDetents([
                            .medium
                        ]).presentationDragIndicator(.visible)
                }.sheet(isPresented: $homeViewModel.isIPSettingSheetPresented) {
                    IPSettingView()
                        .presentationDetents([
                            .height(200)
                        ]).presentationDragIndicator(.visible)
                }
        }
    }
}

private struct HomeContentView: View {
    @ObservedObject private var liarPath: LiarPath
    @ObservedObject private var homeViewModel: HomeViewModel
    
    init(liarPath: LiarPath, homeViewModel: HomeViewModel) {
        self.liarPath = liarPath
        self.homeViewModel = homeViewModel
    }
    
    fileprivate var body: some View {
        VStack(spacing: 10) {
            Image("logo")
                .resizable()
                .scaledToFit()
            CornerButton(
                title: "방만들기",
                fontSize: 48,
                fontWeight: .bold,
                buttonAction: {
                    liarPath.paths.append(.createRoom)
                },
                verticalPadding: 4.0
            )
            CornerButton(
                title: "접속하기",
                fontSize: 48,
                fontWeight: .bold,
                buttonAction: {
                    liarPath.paths.append(.connectRoom)
                },
                verticalPadding: 4.0
            )
            CornerButton(
                title: "게임방법",
                fontSize: 48,
                fontWeight: .bold,
                buttonAction: {
                    homeViewModel.isGameRuleSheetPresented = true
                },
                verticalPadding: 4.0
            )
            CornerButton(
                title: "IP셋팅법",
                fontSize: 48,
                fontWeight: .bold,
                buttonAction: {
                    homeViewModel.isIPSettingSheetPresented = true
                },
                verticalPadding: 4.0
            )
            Spacer()
        }
    }
}

private struct GameRuleView: View {
    fileprivate var body: some View {
        Text("게임 방법")
    }
}

private struct IPSettingView: View {
    fileprivate var body: some View {
        VStack(alignment: .leading) {
            Text("1. 방만들기/접속하기 페이지에서 Load IP를 누른다.")
            Text("2. 만약 이상한 영어와 숫자가 섞인 글이 뜬다면 WIFI를 연결 해제 후 재연결")
            Text("3. IP 수동 확인법 : 설정 - WIFI - 연결된 와이파이 우측 느낌표 버튼 - IPv4 주소 확인")
        }.padding()
    }
}

#Preview {
    HomeView()
}
