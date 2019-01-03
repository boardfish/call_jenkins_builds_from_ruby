require_relative 'jenkins_api_caller'
require 'rspec'
require 'webmock/rspec'
require 'faraday'

WebMock.allow_net_connect!

describe JenkinsApiCaller do
  context 'when a correct IP is provided' do
    context 'when correct credentials are provided' do
      let!(:created_job) { described_class.run_job(job_name: 'hello-world', credentials: credentials, params: { foo: 'test' }) }
      let(:build_status) { described_class.build_status(job_name: 'hello-world', credentials: credentials) }
      it 'authenticates against the Jenkins API' do
        expect(described_class.crumb(credentials)).to be_a String
      end

      it 'makes a call to the Jenkins API' do
        assert_requested :post, 'http://jenkins:8080/job/hello-world/build'
      end

      it 'calls the correct job' do
        begin
          described_class.run_job(
            job_name: 'foobar',
            credentials: credentials(password: 'password'),
            params: { foo: 'bar' }
          )
        rescue Faraday::ClientError => e
        end
        assert_requested :post, 'http://jenkins:8080/job/foobar/build'
      end

      it 'creates a run of the job' do
        expect(created_job.status).to eq(302)
      end

      it 'returns the result of the job' do
        expect(build_status).to be_a Hash
      end

      it 'propagates the parameters' do
        expect(build_status.dig('actions', 0, 'parameters', 0, 'value')).to eq 'test'
      end
    end

    context 'when incorrect credentials are provided' do
      it 'returns an error' do
        expect do
          described_class.run_job(
            job_name: 'hello-world',
            credentials: credentials(password: 'incorrect password'),
            params: { foo: 'this should not have worked...' }
          )
        end.to raise_error Faraday::ClientError
      end
    end
  end
end

def credentials(password: 'password')
  {
    username: 'user',
    password: password,
    host: 'http://jenkins:8080'
  }
end
