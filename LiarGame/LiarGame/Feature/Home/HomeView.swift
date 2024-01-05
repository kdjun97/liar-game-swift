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
        Text("IP 셋팅법")
    }
}

#Preview {
    HomeView()
}
