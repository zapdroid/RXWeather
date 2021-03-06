//
//  Dematerialize.swift
//  RxSwift
//
//  Created by Jamie Pinkham on 3/13/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

fileprivate final class DematerializeSink<Element: EventConvertible, O: ObserverType>: Sink<O>, ObserverType where O.E == Element.ElementType {
    fileprivate func on(_ event: Event<Element>) {
        switch event {
        case let .next(element):
            forwardOn(element.event)
            if element.event.isStopEvent {
                dispose()
            }
        case .completed:
            forwardOn(.completed)
            dispose()
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        }
    }
}

final class Dematerialize<Element: EventConvertible>: Producer<Element.ElementType> {
    private let _source: Observable<Element>

    init(source: Observable<Element>) {
        _source = source
    }

    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element.ElementType {
        let sink = DematerializeSink<Element, O>(observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
