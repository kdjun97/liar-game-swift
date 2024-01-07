//
//  HomeViewModel.swift
//  LiarGame
//
//  Created by 김동준 on 1/1/24
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var isGameRuleSheetPresented: Bool = false
    @Published var isIPSettingSheetPresented: Bool = false
}
