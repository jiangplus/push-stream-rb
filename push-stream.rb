class Values
  def initialize(ary)
    @i = 0
    @ary = ary
    @sink = nil
    @ended = false
  end

  def resume()
    while !@sink.paused && !@ended
      if @i >= @ary.length
        @ended = true
        @sink.ends()
      else
        @sink.write(@ary[@i])
        @i += 1
      end
    end
  end

  def sink=(sk)
    @sink=sk
  end

  def sink()
    @sink
  end

  def pipe(sk)
    @sink = sk
    sk.source = self
    if !sk.paused
      self.resume()
    end
    sk
  end

  def ends()
  end
end

class Collect
  def initialize()
    @ary = []
  end

  def write(x)
    @ary << x
  end

  def paused()
    false
  end

  def ends(err=true)
    @ended = err
    @ary
  end

  def source=(sr)
    @source = sr
  end

  def source
    @source
  end

  def result
    @ary
  end
end

class Map
  def initialize(fn)
    @fn = fn
    @sink = nil
    @paused = true
    @ended = false
  end

  attr_accessor :source, :sink, :paused

  def write(data)
    @sink.write(@fn.call(data))
    @paused = @sink.paused
  end

  def ends(err=true)
    @ended = true
    @sink.ends(err)
  end

  def resume()
    @paused = @sink.paused
    unless @paused
      @source.resume
    end
  end

  def pipe(sk)
    @sink = sk
    sk.source = self
    if !sk.paused
      self.resume()
    end
    sk
  end

end

vals = Values.new([1,2,3])
map = Map.new(->(x) { x*x })
col = Collect.new()
vals.pipe(map)
map.pipe(col)
p col.result
