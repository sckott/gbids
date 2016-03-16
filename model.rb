class GBacc < ActiveRecord::Base
  self.table_name = 'data'
  def self.endpoint(params)
    where(accession: params[:ids].split(','))
      .select('accession')
  end
end

class GBgi < ActiveRecord::Base
  self.table_name = 'data'
  def self.endpoint(params)
    where(gi: params[:ids].split(','))
      .select('gi')
  end
end

class GBacc2gi < ActiveRecord::Base
  self.table_name = 'data'
  def self.endpoint(params)
    where(accession: params[:ids].split(','))
      .select('accession,gi')
  end
end

class GBgi2acc < ActiveRecord::Base
  self.table_name = 'data'
  def self.endpoint(params)
    where(gi: params[:ids].split(','))
      .select('accession,gi')
  end
end

class GBcount < ActiveRecord::Base
  self.table_name = 'data'
end

# list accession ids
class GBgetaccs < ActiveRecord::Base
  self.table_name = 'data'
  def self.endpoint(params)
    params.delete_if { |k, v| v.nil? || v.empty? }

    %i(limit offset).each do |p|
      unless params[p].nil?
        begin
          params[p] = Integer(params[p])
        rescue ArgumentError
          raise Exception.new("#{p.to_s} is not an integer")
        end
      end
    end
    raise Exception.new('limit too large (max 5000)') unless (params[:limit] || 0) <= 5000
    select('accession')
      .limit(params[:limit] || 10)
      .offset(params[:offset])
  end
end

class GBgetgis < ActiveRecord::Base
  self.table_name = 'data'
  def self.endpoint(params)
    params.delete_if { |k, v| v.nil? || v.empty? }

    %i(limit offset).each do |p|
      unless params[p].nil?
        begin
          params[p] = Integer(params[p])
        rescue ArgumentError
          raise Exception.new("#{p.to_s} is not an integer")
        end
      end
    end
    raise Exception.new('limit too large (max 5000)') unless (params[:limit] || 0) <= 5000
    select('gi')
      .limit(params[:limit] || 10)
      .offset(params[:offset])
  end
end
