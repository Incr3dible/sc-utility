package com.tamedia.sc_utility

import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

internal class AsyncWork {
    private val threadPoolExecutor: ThreadPoolExecutor
    private val workQueue: BlockingQueue<Runnable>
    fun run(runnable: Runnable) {
        threadPoolExecutor.execute(runnable)
    }

    fun stop() {
        threadPoolExecutor.shutdown()
    }

    init {
        workQueue = LinkedBlockingQueue()
        threadPoolExecutor = ThreadPoolExecutor(1, 1, 1, TimeUnit.SECONDS, workQueue)
    }
}