require 'faraday'
require 'json'

module JenkinsApiCaller
  class << self
    def run_job(job_name:, credentials:, params: {})
      auth_crumb = crumb(credentials)
      resp = connection(credentials.merge(crumb: auth_crumb))
        .post "/job/#{job_name}/build", "json=#{format_params_for_build(params).to_json}"
    end

    def build_status(job_name:, credentials:)
      auth_crumb = crumb(credentials)
      resp = connection(credentials.merge(crumb: auth_crumb))
        .get "/job/#{job_name}/lastBuild/api/json"
      JSON.parse(resp.body)
    end

    def format_params_for_build(params)
      { parameter: params.map { |key, value| [['name', key], ['value', value]].to_h } }
    end

    def crumb(username:, password:, host:)
      # CRUMB=$(curl -s "$JENKINS_BASE_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" -u $USERNAME:$PASSWORD)
      response = connection(host: host, username: username, password: password).get '/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)'
      response.status == 200 ? response.body : nil
    end

    def connection(host: 'http://jenkins:8080', username: nil, password: nil, crumb: nil)
      Faraday.new(url: host) do |faraday|
        faraday.use Faraday::Response::RaiseError
        faraday.adapter Faraday.default_adapter
        faraday.basic_auth(username, password) if username && password
        faraday.headers[crumb.split(':')[0]] = crumb.split(':')[1] if crumb # FIXME: not robust yet!
      end
    end
  end
end