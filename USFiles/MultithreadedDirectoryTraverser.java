package homework03;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.LinkedList;
import java.util.Set;
import java.util.TreeSet;
import java.util.logging.Level;
import java.util.logging.LogManager;
import java.util.logging.Logger;


public class MultithreadedDirectoryTraverser {

	private final WorkQueue workers;

	private final TreeSet paths;

	private final MultiReaderLock lock;
	
	private static final Logger logger = LogManager.getLogger();
	
	private int pending;
	
	public MultithreadedDirectoryTraverser() {
		workers = new WorkQueue();
	}
	
	public synchronized void traverseDirectory(Path dir){
		try {
			 if (Files.isDirectory(dir)) {
                 workers.execute(new DirectoryWorker(dir));
         }
         else{
                 getPaths(dir);
         }
		catch (IOException e) {
			logger.warn("Unable to traverse files for {}", dir);
			logger.catching(Level.DEBUG, e);
		}
	}

	public synchronized Set getPaths(Path dir){
		finish();
		logger.debug("Getting Paths");
		paths = Collections.unmodifiableSet(new TreeSet());
	}

	public synchronized void finish() {
        try {
                while (pending > 0) {
                        logger.debug("Waiting until finished");
                        this.wait();
                }
        }
        catch (InterruptedException e) {
                logger.debug("Finish interrupted", e);
        }
}
	public synchronized void shutdown(){
		logger.debug("Shutting down");
		finish();
		workers.shutdown();
	}
	
	private class DirectoryWorker implements Runnable {

		private Path dir;

		public DirectoryWorker(Path dir) {
			logger.debug("Worker created for {}", dir);
			this.dir = dir;
			incrementPending();
		}

		@Override
		public void run() {
			try {
				for (Path path : Files.newDirectoryStream(dir)) {
					if (Files.isDirectory(path)) {
						workers.execute(new DirectoryWorker(path));
					}
					else{
		                 getPaths(dir);
			         }
					}
				decrementPending();
			}
			catch (IOException e) {
				logger.warn("Unable to parse {}", dir);
				logger.catching(Level.DEBUG, e);
			}

			logger.debug("Worker finished {}", dir);
		}



		/**
		 * Indicates that we now have additional "pending" work to wait for. We
		 * need this since we can no longer call join() on the threads. (The
		 * threads keep running forever in the background.)
		 *
		 * We made this a synchronized method in the outer class, since locking
		 * on the "this" object within an inner class does not work.
		 */
		private synchronized void incrementPending() {
			pending++;
			logger.debug("Pending is now {}", pending);
		}

		/**
		 * Indicates that we now have one less "pending" work, and will notify
		 * any waiting threads if we no longer have any more pending work left.
		 */
		private synchronized void decrementPending() {
			pending--;
			logger.debug("Pending is now {}", pending);

			if (pending <= 0) {
				this.notifyAll();
			}
		}
	}
	
	 class WorkQueue {

		/** Pool of worker threads that will wait in the background until work is available. */
		private final PoolWorker[] workers;

		/** Queue of pending work requests. */
		private final LinkedList<Runnable> queue;

		/** Used to signal the queue should be shutdown. */
		private volatile boolean shutdown;

		/** The default number of threads to use when not specified. */
		public static final int DEFAULT = 5;

		/**
		 * Starts a work queue with the default number of threads.
		 * @see #WorkQueue(int)
		 */
		public WorkQueue() {
			this(DEFAULT);
		}

		/**
		 * Starts a work queue with the specified number of threads.
		 *
		 * @param threads number of worker threads; should be greater than 1
		 */
		public WorkQueue(int threads) {
			this.queue   = new LinkedList<Runnable>();
			this.workers = new PoolWorker[threads];

			shutdown = false;

			// start the threads so they are waiting in the background
			for (int i = 0; i < threads; i++) {
				workers[i] = new PoolWorker();
				workers[i].start();
			}
		}

		/**
		 * Adds a work request to the queue. A thread will process this request
		 * when available.
		 *
		 * @param r work request (in the form of a {@link Runnable} object)
		 */
		public void execute(Runnable r) {
			synchronized (queue) {
				queue.addLast(r);
				queue.notifyAll();
			}
		}

		/**
		 * Asks the queue to shutdown. Any unprocessed work will not be finished,
		 * but threads in-progress will not be interrupted.
		 */
		public void shutdown() {
			shutdown = true;

			synchronized (queue) {
				queue.notifyAll();
			}
		}

		/**
		 * Returns the number of worker threads being used by the work queue.
		 *
		 * @return number of worker threads
		 */
		public int size() {
			return workers.length;
		}

		/**
		 * Waits until work is available in the work queue. When work is found, will
		 * remove the work from the queue and run it. If a shutdown is detected,
		 * will exit instead of grabbing new work from the queue. These threads will
		 * continue running in the background until a shutdown is requested.
		 */
		private class PoolWorker extends Thread {

			@Override
			public void run() {
				Runnable r = null;

				while (true) {
					synchronized (queue) {
						while (queue.isEmpty() && !shutdown) {
							try {
								queue.wait();
							}
							catch (InterruptedException ignored) {
								System.out.println("Warning: Work queue interrupted " +
										"while waiting.");
							}
						}

						if (shutdown) {
							break;
						}
						else {
							r = queue.removeFirst();
						}
					}

					try {
						r.run();
					}
					catch (RuntimeException ex) {
						System.out.println("Warning: Work queue encountered an " +
								"exception while running.");
					}
				}
			}
		}
	}
}

 class MultiReaderLock {
	 
	private int readers;
	private int writers;

	/**
	 * Initializes a multi-reader (single-writer) lock.
	 */
	public MultiReaderLock() {
		this.readers = 0;
		this.writers = 0;
	}

	/**
	 * Will wait until there are no active writers in the system, and then will
	 * increase the number of active readers.
	 */
	public synchronized void lockRead() {
		while (writers > 0) {
			try { 
		      this.wait(); 
       }
			catch (InterruptedException ex) {
			}
	}
	readers++;
	}

	/**
	 * Will decrease the number of active readers, and notify any waiting
	 * threads if necessary.
	 */
	public synchronized void unlockRead() {
		readers--;
		notifyAll();
	}

	/**
	 * Will wait until there are no active readers or writers in the system, and
	 * then will increase the number of active writers.
	 */
	public synchronized void lockWrite() {
		while (readers > 0 || writers > 0) {
			try { 
		      this.wait(); 
       }
			catch (InterruptedException ex) {
			}
	}
	writers++;
	}

	/**
	 * Will decrease the number of active writers, and notify any waiting
	 * threads if necessary.
	 */
	public synchronized void unlockWrite() {
		writers--;
		notifyAll();
	}
}
