require 'spec_helper'

describe 'jenkins::cli::config', type: :class do
  shared_examples 'validate_absolute_path' do |param|
    context 'absolute path' do
      let(:params) { { param => '/dne' } }

      it { is_expected.not_to raise_error }
    end
  end # validate_absolute_path

  shared_examples 'validate_integer' do |param|
    context 'integer' do
      let(:params) { { param => 42 } }

      it { is_expected.not_to raise_error }
    end
  end # validate_integer

  shared_examples 'validate_numeric' do |param|
    context 'integer' do
      let(:params) { { param => 42 } }

      it { is_expected.not_to raise_error }
    end

    context 'float' do
      let(:params) { { param => 42.12345 } }

      it { is_expected.not_to raise_error }
    end
  end # validate_numeric

  shared_examples 'validate_string' do |param|
    context 'string' do
      let(:params) { { param => 'foo' } }

      it { is_expected.not_to raise_error }
    end
  end # validate_string

  describe 'parameters' do
    context 'accept all params undef' do
      it { is_expected.not_to raise_error }
    end

    describe 'cli_jar' do
      it_behaves_like 'validate_absolute_path', :cli_jar
    end

    # context 'port' do
    #   it_behaves_like 'validate_integer', :port
    # end
    context 'url' do
      it_behaves_like 'validate_string', :url
    end

    context 'ssh_private_key' do
      it_behaves_like 'validate_absolute_path', :ssh_private_key
    end

    context 'puppet_helper' do
      it_behaves_like 'validate_absolute_path', :puppet_helper
    end

    context 'cli_tries' do
      it_behaves_like 'validate_integer', :cli_tries
    end

    context 'cli_try_sleep' do
      it_behaves_like 'validate_numeric', :cli_try_sleep
    end

    context 'ssh_private_key_content' do
      it_behaves_like 'validate_string', :ssh_private_key_content

      context 'when ssh_private_key is also set' do
        let(:params) do
          {
            ssh_private_key: '/dne',
            ssh_private_key_content: 'foo'
          }
        end

        context 'as non-root user' do
          let(:facts) { { id: 'user' } }

          it do
            is_expected.to contain_file('/dne').with(
              ensure: 'file',
              mode: '0400',
              backup: false,
              owner: nil,
              group: nil
            )
          end
          it { is_expected.to contain_file('/dne').with_content('foo') }
        end # as non-root user

        context 'as root' do
          let(:facts) { { id: 'root' } }

          it do
            is_expected.to contain_file('/dne').with(
              ensure: 'file',
              mode: '0400',
              backup: false,
              owner: 'jenkins',
              group: 'jenkins'
            )
          end
          it { is_expected.to contain_file('/dne').with_content('foo') }
        end # as root
      end # when ssh_private_key is also set
    end # ssh_private_key_content
  end # parameters

  describe 'package gem provider' do
    context 'is_pe fact' do
      context 'true' do
        let(:facts) { { is_pe: true } }

        it { is_expected.to contain_package('retries').with(provider: 'pe_gem') }
      end

      context 'false' do
        let(:facts) { { is_pe: false } }

        it { is_expected.to contain_package('retries').with(provider: 'gem') }
      end
    end # 'is_pe fact' do

    context 'puppetversion facts' do
      context '=> 3.8.4' do
        let(:facts) { { puppetversion: '3.8.4' } }

        it { is_expected.to contain_package('retries').with(provider: 'gem') }
      end

      context '=> 4.0.0' do
        let(:facts) { { puppetversion: '4.0.0' } }

        it { is_expected.to contain_package('retries').with(provider: 'gem') }

        context 'rubysitedir fact' do
          context '=> /foo/bar' do
            before { facts[:rubysitedir] = '/foo/bar' }
            it { is_expected.to contain_package('retries').with(provider: 'gem') }
          end

          context '=> /opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0' do
            before { facts[:rubysitedir] = '/opt/puppetlabs/puppet/lib/ruby/site_ruby/2.1.0' }
            it { is_expected.to contain_package('retries').with(provider: 'puppet_gem') }
          end
        end
      end
    end # 'puppetversion facts' do
  end # 'package gem provider' do
end
