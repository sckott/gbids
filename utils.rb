# helpers
def match_id_acc
  begin
    data = GBacc.endpoint(params)
  raise Exception.new('no results found') if data.length.zero?
    ids = params[:ids].split(',')
    matches = ids.map { |x| data.collect { |x| x.accession }.include? x }
    dat = Hash[ids.zip matches]
    { matched: data.limit(nil).count(1), returned: dat.length, data: dat, error: nil }.to_json
  rescue Exception => e
    halt 400, err_body(e)
  end
end

def match_id_gi
  begin
    data = GBgi.endpoint(params)
  raise Exception.new('no results found') if data.length.zero?
    ids = params[:ids].split(',')
    matches = ids.map { |x| data.collect { |x| x.gi }.to_s.include? x }
    dat = Hash[ids.zip matches]
    { matched: data.limit(nil).count(1), returned: dat.length, data: dat, error: nil }.to_json
  rescue Exception => e
    halt 400, err_body(e)
  end
end

def get_gi
  begin
    data = GBacc2gi.endpoint(params)
  raise Exception.new('no results found') if data.length.zero?
    ids = params[:ids].split(',')
    datahash = data.as_json
    accs = datahash.collect { |x| x['accession'] }
    idsnomatch = ids - accs
    idsnomatch.collect{|x| datahash.append({"accession" => x, "gi" => nil}) }.flatten
    { matched: data.limit(nil).count(1), returned: datahash.length, data: datahash, error: nil }.to_json
  rescue Exception => e
    halt 400, err_body(e)
  end
end

def get_acc
  begin
    data = GBgi2acc.endpoint(params)
  raise Exception.new('no results found') if data.length.zero?
    ids = params[:ids].split(',')
    datahash = data.as_json
    gis = datahash.collect { |x| x['gi'].to_s }
    idsnomatch = ids - gis
    idsnomatch.collect{|x| datahash.append({"gi" => x, "accession" => nil}) }.flatten
    { matched: data.limit(nil).count(1), returned: datahash.length, data: datahash, error: nil }.to_json
  rescue Exception => e
    halt 400, err_body(e)
  end
end

# list accession ids
def get_accs(params)
  begin
    data = GBgetaccs.endpoint(params)
  raise Exception.new('no results found') if data.length.zero?
    dat = data.as_json.map(&:values).flatten
    { matched: data.limit(nil).count(1), returned: dat.length, data: dat, error: nil }.to_json
  rescue Exception => e
    halt 400, err_body(e)
  end
end

def get_gis(params)
  begin
    data = GBgetgis.endpoint(params)
  raise Exception.new('no results found') if data.length.zero?
    dat = data.as_json.map(&:values).map(&:compact).flatten
    { matched: data.limit(nil).count(1), returned: dat.length, data: dat, error: nil }.to_json
  rescue Exception => e
    halt 400, err_body(e)
  end
end



def err_body(e)
  return { matched: 0, returned: 0, data: nil, error: { message: e.message }}.to_json
end
