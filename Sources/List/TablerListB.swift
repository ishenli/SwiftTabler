//
//  TablerListB.swift
//
// Copyright 2022 FlowAllocator LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

/// List-based table, with support for bound value types
public struct TablerListB<Element, Header, Row, RowBack, RowOver, Results>: View
    where Element: Identifiable,
    Header: View,
    Row: View,
    RowBack: View,
    RowOver: View,
    Results: RandomAccessCollection & MutableCollection,
    Results.Element == Element,
    Results.Index: Hashable
{
    public typealias Config = TablerListConfig<Element>
    public typealias Context = TablerContext<Element>
    public typealias Hovered = Element.ID?
    public typealias HeaderContent = (Binding<Context>) -> Header
    public typealias RowContent = (Binding<Element>) -> Row
    public typealias RowBackground = (Element) -> RowBack
    public typealias RowOverlay = (Element) -> RowOver

    // MARK: Parameters

    private let config: Config
    private let headerContent: HeaderContent
    private let rowContent: RowContent
    private let rowBackground: RowBackground
    private let rowOverlay: RowOverlay
    @Binding private var results: Results

    public init(_ config: Config = .init(),
                @ViewBuilder header: @escaping HeaderContent,
                @ViewBuilder row: @escaping RowContent,
                @ViewBuilder rowBackground: @escaping RowBackground,
                @ViewBuilder rowOverlay: @escaping RowOverlay,
                results: Binding<Results>)
    {
        self.config = config
        headerContent = header
        rowContent = row
        self.rowBackground = rowBackground
        self.rowOverlay = rowOverlay
        _results = results
        _context = State(initialValue: TablerContext(config))
    }

    // MARK: Locals

    @State private var hovered: Hovered = nil
    @State private var context: Context

    // MARK: Views

    public var body: some View {
        BaseList(context: $context,
                 header: headerContent) {
            // TODO: is there a better way to filter bound data source?
            if let _filter = config.filter {
                ForEach($results) { $element in
                    if _filter(element) {
                        row($element)
                    }
                }
                .onMove(perform: config.onMove)
            } else {
                ForEach($results) { $element in
                    row($element)
                }
                .onMove(perform: config.onMove)
            }
        }
    }

    private func row(_ element: Binding<Element>) -> some View {
        rowContent(element)
            .modifier(ListRowMod(config: config,
                                 element: element.wrappedValue,
                                 hovered: $hovered))
            .listRowBackground(rowBackground(element.wrappedValue))
            .overlay(rowOverlay(element.wrappedValue))
    }
}

public extension TablerListB {
    // omitting Header
    init(_ config: Config,
         @ViewBuilder row: @escaping RowContent,
         @ViewBuilder rowBackground: @escaping RowBackground,
         @ViewBuilder rowOverlay: @escaping RowOverlay,
         results: Binding<Results>)
        where Header == EmptyView
    {
        self.init(config,
                  header: { _ in EmptyView() },
                  row: row,
                  rowBackground: rowBackground,
                  rowOverlay: rowOverlay,
                  results: results)
    }

    // omitting Overlay
    init(_ config: Config,
         @ViewBuilder header: @escaping HeaderContent,
         @ViewBuilder row: @escaping RowContent,
         @ViewBuilder rowBackground: @escaping RowBackground,
         results: Binding<Results>)
        where RowOver == EmptyView
    {
        self.init(config,
                  header: header,
                  row: row,
                  rowBackground: rowBackground,
                  rowOverlay: { _ in EmptyView() },
                  results: results)
    }

    // omitting Background
    init(_ config: Config,
         @ViewBuilder header: @escaping HeaderContent,
         @ViewBuilder row: @escaping RowContent,
         @ViewBuilder rowOverlay: @escaping RowOverlay,
         results: Binding<Results>)
        where RowBack == EmptyView
    {
        self.init(config,
                  header: header,
                  row: row,
                  rowBackground: { _ in EmptyView() },
                  rowOverlay: rowOverlay,
                  results: results)
    }

    // omitting Header AND Overlay
    init(_ config: Config,
         @ViewBuilder row: @escaping RowContent,
         @ViewBuilder rowBackground: @escaping RowBackground,
         results: Binding<Results>)
        where Header == EmptyView, RowOver == EmptyView
    {
        self.init(config,
                  header: { _ in EmptyView() },
                  row: row,
                  rowBackground: rowBackground,
                  rowOverlay: { _ in EmptyView() },
                  results: results)
    }
    
    // omitting Header AND Background
    init(_ config: Config,
         @ViewBuilder row: @escaping RowContent,
         @ViewBuilder rowOverlay: @escaping RowOverlay,
         results: Binding<Results>)
        where Header == EmptyView, RowBack == EmptyView
    {
        self.init(config,
                  header: { _ in EmptyView() },
                  row: row,
                  rowBackground: { _ in EmptyView() },
                  rowOverlay: rowOverlay,
                  results: results)
    }
    
    // omitting Background AND Overlay
    init(_ config: Config,
         @ViewBuilder header: @escaping HeaderContent,
         @ViewBuilder row: @escaping RowContent,
         results: Binding<Results>)
        where RowBack == EmptyView, RowOver == EmptyView
    {
        self.init(config,
                  header: header,
                  row: row,
                  rowBackground: { _ in EmptyView() },
                  rowOverlay: { _ in EmptyView() },
                  results: results)
    }

    // omitting Header, Background, AND Overlay
    init(_ config: Config,
         @ViewBuilder row: @escaping RowContent,
         results: Binding<Results>)
        where Header == EmptyView, RowBack == EmptyView, RowOver == EmptyView
    {
        self.init(config,
                  header: { _ in EmptyView() },
                  row: row,
                  rowBackground: { _ in EmptyView() },
                  rowOverlay: { _ in EmptyView() },
                  results: results)
    }
}
