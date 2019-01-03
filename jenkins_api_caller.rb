require 'faraday'
require 'json'

##
# Calls the Jenkins API with the purpose of starting and monitoring jobs.
module JenkinsApiCaller
  CRUMB_ISSUER_URI = '/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,"' \
                     ':",//crumb)'.freeze
  class << self
    def run_job(job_name:, credentials:, params: {})
      auth_crumb = crumb(credentials)
      connection(credentials.merge(crumb: auth_crumb))
        .post "/job/#{job_name}/build",
              "json=#{format_params_for_build(params).to_json}"
    end

    def build_status(job_name:, credentials:)
      auth_crumb = crumb(credentials)
      resp = connection(credentials.merge(crumb: auth_crumb))
             .get "/job/#{job_name}/lastBuild/api/json"
      JSON.parse(resp.body)
    end

    def format_params_for_build(params)
      { parameter: params.map do |key, value|
                     [['name', key], ['value', value]].to_h
                   end }
    end

    def crumb(username:, password:, host:)
      resp = connection(host: host, username: username, password: password)
             .get CRUMB_ISSUER_URI
      resp.status == 200 ? resp.body : nil
    end

    def header(string, index)
      split_string = string.split(':')
      split_string[[index, split_string.length - 1].min]
    end

    def connection(host:, username: nil, password: nil, crumb: nil)
      Faraday.new(url: host) do |faraday|
        faraday.use Faraday::Response::RaiseError
        faraday.adapter Faraday.default_adapter
        faraday.basic_auth(username, password) if username && password
        faraday.headers[header(crumb, 0)] = header(crumb, 1) if crumb
      end
    end
  end
end
