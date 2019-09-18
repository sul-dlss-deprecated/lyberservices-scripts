require 'spec_helper'

describe PreAssembly::Utils do

  it 'should read in a list of completed druids from a progress log file' do
    progress_filename = 'spec/test_data/test_log.yaml'
    druids = PreAssembly::Utils.get_druids_from_log(progress_filename)
    expect(druids).to eq(['druid:bc006dj2846', 'druid:bg598tg6338'])
  end

  it 'should read in a list of failed druids from a progress log file' do
    progress_filename = 'spec/test_data/test_log.yaml'
    druids = PreAssembly::Utils.get_druids_from_log(progress_filename, false)
    expect(druids).to eq(['druid:bh634sp8073'])
  end

end
