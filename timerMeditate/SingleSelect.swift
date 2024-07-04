//
//  SingleSelect.swift
//  timerMeditate
//
//  Created by Daniel Braithwaite on 13/5/2024.
//

import Foundation
import SwiftUI

struct SingleSelect<Item: Identifiable, Content: View>: View {
    
    var items: [Item]
    @Binding var selectedItem: Item?
    var rowContent: (Item) -> Content
    
    var body: some View {
        List(items) { item in
            rowContent(item)
                .modifier(CheckmarkModifier(checked: item.id == self.selectedItem?.id))
                .contentShape(Rectangle())
                .onTapGesture {
                    self.selectedItem = item
                }
        }
    }
}

struct CheckmarkModifier: ViewModifier {
    var checked: Bool = false
    func body(content: Content) -> some View {
        Group {
            if checked {
                ZStack(alignment: .trailing) {
                    content
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.green)
                        .shadow(radius: 1)
                }
            } else {
                content
            }
        }
    }
}
