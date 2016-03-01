  # random accession numbers
  get '/random/acc/?' do
    get_random_acc
  end

  # random GI numbers
  get '/random/gi/?' do
    get_random_gi
  end

  def get_random(x)
    n = params[:n] || 10
    count = GBcount.count
    res = n.to_i.times.collect { x.randomkey }
    return MultiJson.dump(res)
  end

  def get_random_acc
    get_random($redis1)
  end

  def get_random_gi
    get_random($redis2)
  end
