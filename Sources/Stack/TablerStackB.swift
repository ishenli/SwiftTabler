//
//  TablerStackB.swift
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

/// Stack-based table, with support for bound values
public struct TablerStackB<Element, Header, Row, Results>: View
    where Element: Identifiable,
    Header: View,
    Row: View,
    Results: RandomAccessCollection & MutableCollection,
    Results.Element == Element,
    Results.Index: Hashable
{
    public typealias Config = TablerStackConfig<Element>
    public typealias Hovered = Element.ID?
    public typealias HeaderContent = (Binding<TablerSort<Element>?>) -> Header
    public typealias RowContent = (Binding<Element>) -> Row

    // MARK: Parameters

    private let config: Config
    private let headerContent: HeaderContent
    private let rowContent: RowContent
    @Binding private var results: Results

    public init(_ config: Config,
                @ViewBuilder headerContent: @escaping HeaderContent,
                @ViewBuilder rowContent: @escaping RowContent,
                results: Binding<Results>)
    {
        self.config = config
        self.headerContent = headerContent
        self.rowContent = rowContent
        _results = results
    }

    // MARK: Locals

    @State private var hovered: Hovered = nil

    // MARK: Views

    public var body: some View {
        BaseStack(config: config,
                  headerContent: headerContent) {
            // TODO: is there a better way to filter bound data source?
            if let _filter = config.filter {
                ForEach($results) { $element in
                    if _filter(element) {
                        row($element)
                    }
                }
            } else {
                ForEach($results) { $element in
                    row($element)
                }
            }
        }
    }

    private func row(_ element: Binding<Element>) -> some View {
        BaseStackRow(config: config,
                     element: element.wrappedValue,
                     hovered: $hovered) {
            rowContent(element)
        }
    }
}

public extension TablerStackB {
    // omitting Header
    init(_ config: Config,
         @ViewBuilder rowContent: @escaping RowContent,
         results: Binding<Results>)
        where Header == EmptyView
    {
        self.init(config,
                  headerContent: { _ in EmptyView() },
                  rowContent: rowContent,
                  results: results)
    }
}
