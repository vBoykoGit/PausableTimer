//
//  PausableTimerSpec.swift
//  PausableTimer
//
//  Created by Kohei Tabata on 6/12/16.
//  Copyright © 2016 Kohei Tabata. All rights reserved.
//

import Quick
import Nimble

@testable import PausableTimer

class PausableTimerSpec: QuickSpec {
    override func spec() {
        describe("PausableTimer") {
            describe("setDuration(duration: TimeInterval)", {
                it("will update duration with passed value", closure: {
                    let timer: PausableTimer = PausableTimer()

                    expect(timer.remainingDuration()).to(equal(0))

                    let duration: TimeInterval = 300
                    timer.setDuration(duration)

                    expect(timer.remainingDuration()).to(equal(duration))
                })
            })


            describe("isRunning()", {
                context("with start action", {
                    context("and called within duration", {
                        it("will return true", closure: {
                            let timer: PausableTimer = PausableTimer()

                            let duration: TimeInterval = 10
                            let diff: TimeInterval     = 5
                            let startDate: Date        = Date()
                            let now: Date              = startDate.addingTimeInterval(diff)

                            timer.setDuration(duration)
                            timer.start(startDate)

                            expect(timer.isRunning(now)).to(beTrue())
                        })
                    })
                    context("and called after duration", {
                        it("will return false", closure: {
                            let timer: PausableTimer = PausableTimer()

                            let duration: TimeInterval = 5
                            let diff: TimeInterval     = 6
                            let startDate: Date        = Date()
                            let now: Date              = startDate.addingTimeInterval(diff)

                            timer.setDuration(duration)
                            timer.start(startDate)

                            expect(timer.isRunning(now)).to(beFalse())
                        })
                    })
                    context("and pause action", {
                        it("will return false", closure: {
                            let timer: PausableTimer = PausableTimer()

                            let duration: TimeInterval = 10

                            let startDate: Date = Date()
                            let pauseDate: Date = startDate.addingTimeInterval(5)
                            let now: Date       = startDate.addingTimeInterval(6)

                            timer.setDuration(duration)
                            timer.start(startDate)

                            timer.pause(pauseDate)

                            expect(timer.isRunning(now)).to(beFalse())
                        })
                    })
                    context(", pause action and resume action", {
                        it("will return true", closure: {
                            let timer: PausableTimer = PausableTimer()

                            let duration: TimeInterval = 10

                            let startDate: Date  = Date()
                            let pauseDate: Date  = startDate.addingTimeInterval(5)

                            let resumeDate: Date = startDate.addingTimeInterval(6)
                            let now: Date        = resumeDate.addingTimeInterval(2)


                            timer.setDuration(duration)
                            timer.start(startDate)

                            timer.pause(pauseDate)

                            timer.resume(resumeDate)
                            
                            expect(timer.isRunning(now)).to(beTrue())
                        })
                    })
                })
                context("without start action", {
                    it("will return false", closure: {
                        let timer: PausableTimer = PausableTimer()

                        timer.setDuration(200)

                        expect(timer.isRunning()).to(beFalse())
                    })
                })
            })


            describe("remainingDuration(now: Date)", {
                context("with startDate", {
                    context("and now argument which diff between startDate exceeds duration", {
                        it("will return 0", closure: {
                            let timer: PausableTimer = PausableTimer()

                            let duration: TimeInterval = 10
                            let startDate: Date        = Date()
                            let now: Date              = startDate.addingTimeInterval(15)

                            timer.setDuration(duration)

                            timer.start(startDate)

                            expect(timer.remainingDuration(now)).to(equal(0))
                        })
                    })
                    context("and now argument which diff between startDate does not exceeds duration", {
                        it("will return (duration - (diff between startDate and now argument))", closure: {
                            let timer: PausableTimer = PausableTimer()

                            let duration: TimeInterval = 10
                            let diff: TimeInterval     = 4
                            let startDate: Date        = Date()
                            let now: Date              = startDate.addingTimeInterval(diff)

                            timer.setDuration(duration)

                            timer.start(startDate)
                            
                            expect(timer.remainingDuration(now)).to(equal(duration - diff))
                        })
                    })
                    context("and pauseDate", {
                        it("will return (duration - (diff between startDate and pauseDate argument))", closure: {
                            let timer: PausableTimer = PausableTimer()

                            let duration: TimeInterval = 10
                            let diff: TimeInterval     = 4
                            let startDate: Date = Date()
                            let pauseDate: Date = startDate.addingTimeInterval(diff)
                            let now: Date       = startDate.addingTimeInterval(9)

                            timer.setDuration(duration)

                            timer.start(startDate)
                            timer.pause(pauseDate)

                            expect(timer.remainingDuration(now)).to(equal(duration - diff))
                        })
                    })
                    context(", pauseDate and resumeDate", {
                        it("will return (duration - (diff between startDate and pauseDate) - (diff between resumeDate and now argument))", closure: {
                            let timer: PausableTimer = PausableTimer()

                            let duration: TimeInterval          = 10
                            let diffForPauseDate: TimeInterval  = 4
                            let diffForResumeDate: TimeInterval = 6
                            let diffForNow: TimeInterval        = 2
                            let startDate: Date  = Date()
                            let pauseDate: Date  = startDate.addingTimeInterval(diffForPauseDate)
                            let resumeDate: Date = startDate.addingTimeInterval(diffForResumeDate)
                            let now: Date        = resumeDate.addingTimeInterval(diffForNow)

                            timer.setDuration(duration)

                            timer.start(startDate)
                            timer.pause(pauseDate)
                            timer.resume(resumeDate)

                            expect(timer.remainingDuration(now)).to(equal(duration - diffForPauseDate - diffForNow))
                        })
                    })
                })
                context("without startDate", {
                    it("will return set duration value", closure: {
                        let timer: PausableTimer = PausableTimer()

                        let duration: TimeInterval = 900

                        timer.setDuration(duration)

                        expect(duration).to(equal(duration))
                    })
                })
            })


            describe("didStart", {
                it("will be invoked when start() is called", closure: {
                    let timer: PausableTimer = PausableTimer()
                    var didInvoked: Bool = false

                    timer.didStart = {
                        didInvoked = true
                    }

                    timer.start()

                    expect(didInvoked).toEventually(beTrue())
                })
            })
            describe("didPause", {
                context("after start action calling", {
                    it("will be invoked when pause() is called", closure: {
                        let timer: PausableTimer = PausableTimer()
                        let duration: TimeInterval = 20
                        let startDate: Date        = Date()
                        let pauseDate: Date        = startDate.addingTimeInterval(10)
                        var didInvoked: Bool = false

                        timer.setDuration(duration)

                        timer.didPause = {
                            didInvoked = true
                        }

                        timer.start(startDate)
                        timer.pause(pauseDate)

                        expect(didInvoked).toEventually(beTrue())
                    })
                })
                context("under status not calling start action ", {
                    it("will not be invoked when pause() is called", closure: {
                        let timer: PausableTimer = PausableTimer()
                        let duration: TimeInterval = 20
                        let pauseDate: Date        = Date()
                        var didInvoked: Bool = false

                        timer.setDuration(duration)

                        timer.didPause = {
                            didInvoked = true
                        }

                        timer.pause(pauseDate)
                        
                        expect(didInvoked).toEventually(beFalse())
                    })
                })
            })
            describe("didResume", {
                it("will be invoked when resume() is called", closure: {
                    let timer: PausableTimer = PausableTimer()


                    let duration: TimeInterval = 20
                    let startDate: Date  = Date()
                    let pauseDate: Date  = startDate.addingTimeInterval(5)
                    let resumeDate: Date = startDate.addingTimeInterval(10)
                    var didInvoked: Bool = false

                    timer.setDuration(duration)

                    timer.didResume = {
                        didInvoked = true
                    }

                    timer.start(startDate)
                    timer.pause(pauseDate)
                    timer.resume(resumeDate)

                    expect(didInvoked).toEventually(beTrue())
                })
            })
            describe("didStop", {
                context("with stop action", {
                    it("will be invoked with false argument", closure: {
                        let timer: PausableTimer = PausableTimer()
                        let duration: TimeInterval = 20
                        let startDate: Date = Date()
                        var didInvoked: Bool = false
                        var isFinished: Bool = false

                        timer.setDuration(duration)

                        timer.didStop = { finished in
                            didInvoked = true
                            isFinished = finished
                        }

                        timer.start(startDate)
                        timer.stop()

                        expect(didInvoked).toEventually(beTrue())
                        expect(isFinished).toEventually(beFalse())
                    })
                })
                context("with the passage of duration", {
                    it("will be invoked with true argument", closure: {
                        let timer: PausableTimer = PausableTimer()
                        let duration: TimeInterval = 1
                        let startDate: Date = Date()
                        let stopDate: Date  = startDate.addingTimeInterval(1.5)
                        var didInvoked: Bool = false
                        var isFinished: Bool = false

                        timer.setDuration(duration)

                        timer.didStop = { finished in
                            didInvoked = true
                            isFinished = finished
                        }

                        timer.start(startDate)

                        RunLoop.current.run(until: stopDate as Date)

                        expect(didInvoked).toEventually(beTrue())
                        expect(isFinished).toEventually(beTrue())
                    })
                })
            })
        }
    }
}
