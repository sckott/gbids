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
