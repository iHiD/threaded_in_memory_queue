require 'test_helper'

class MasterTest < Test::Unit::TestCase

  def test_thread_worker_creation
    size   = 1
    master = ThreadedInMemoryQueue::Master.new(size: size)
    master.start
    assert_equal size, master.workers.size
    master.stop

    size   = 3
    master = ThreadedInMemoryQueue::Master.new(size: size)
    master.start
    assert_equal size, master.workers.size
    master.stop

    size   = 6
    master = ThreadedInMemoryQueue::Master.new(size: size)
    master.start
    assert_equal size, master.workers.size
    master.stop

    size   = 16
    master = ThreadedInMemoryQueue::Master.new(size: size)
    master.start
    assert_equal size, master.workers.size
    master.stop
  end

  def test_calls_contents_of_blocks
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    master = ThreadedInMemoryQueue::Master.new(size: 1)
    master.start

    job = Proc.new {|x| Dummy.process(x) }

    master.enqueue(job, 1)
    master.enqueue(job, 2)
    master.stop
  end

  def test_calls_context_of_klass
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    job = Class.new do
      def self.call(num)
        Dummy.process(num)
      end
    end

    master = ThreadedInMemoryQueue::Master.new(size: 1)
    master.start
    master.enqueue(job, 1)
    master.enqueue(job, 2)
    master.stop
  end
end
