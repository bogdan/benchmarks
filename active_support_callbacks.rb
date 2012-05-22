$:.unshift("./lib")
require "active_support/callbacks"
require "diffbench"
GC.disable


module Definition
  def self.included(base)
    base.class_eval do
      define_callbacks :save

      10.times do
        set_callback :save, :before, :before_save1
        set_callback :save, :after, :after_save1
        set_callback :save, :around, :around_save1
      end

      def before_save1;nil; end
      def after_save1; nil; end
      def around_save1; nil; end

      def save(key = nil)
        run_callbacks :save do
          true
        end
      end

    end
  end
end

class NewClass
  include ActiveSupport::Callbacks
  include Definition
end
new = NewClass.new

class EmptyClass
  include ActiveSupport::Callbacks
  include Definition
  reset_callbacks :save
end
empty = EmptyClass.new

DiffBench.bm do |x|
  x.report "set_callback" do
    amount = 10
    amount.times do
      Class.new do
        include ActiveSupport::Callbacks
        include Definition
      end
    end
  end
  x.report "define_callbacks" do
    new_klass = Class.new do
      include ActiveSupport::Callbacks
    end
    amount = 100

    amount.times do |i|
      new_klass.send(:define_callbacks, :"save#{i}")
    end
  end
  x.report "run_callbacks when empty" do
    amount = 1000
    amount.times do
      empty.save
    end
  end
  x.report "run_callbacks when not empty" do
    amount = 1000
    amount.times do
      new.save
    end
  end
  x.report "skip_callback" do
    amount = 100
    klass = Class.new do
      include ActiveSupport::Callbacks
      include Definition
    end
    amount.times do |index|
      klass.skip_callback :save, :before, :before_save1, :if => "false"
    end
  end
end

GC.enable
