require 'spec_helper'
require '{{package_name}}'

RSpec.describe {{package_name | title_case}} do
  let(:service) { {{package_name | title_case}}.create_service }
  
  describe '#create_service' do
    it 'creates a new service instance' do
      expect(service).to be_a({{package_name | title_case}}::Service)
    end
  end
  
  describe {{package_name | title_case}}::Service do
    describe '#process' do
      it 'processes input string with context' do
        input = 'hello'
        context = 'test-context'
        expected = 'HELLO'
        
        result = service.process(input, context)
        
        expect(result).to eq(expected)
      end
      
      it 'handles empty input' do
        input = ''
        context = 'test-context'
        expected = ''
        
        result = service.process(input, context)
        
        expect(result).to eq(expected)
      end
      
      it 'handles special characters' do
        input = 'hello@world#123'
        context = 'test-context'
        expected = 'HELLO@WORLD#123'
        
        result = service.process(input, context)
        
        expect(result).to eq(expected)
      end
      
      it 'handles unicode characters' do
        input = 'héllo wörld'
        context = 'test-context'
        expected = 'HÉLLO WÖRLD'
        
        result = service.process(input, context)
        
        expect(result).to eq(expected)
      end
      
      it 'logs processing information' do
        allow({{package_name | title_case}}::LOGGER).to receive(:info)
        
        input = 'test'
        context = 'test-context'
        
        service.process(input, context)
        
        expect({{package_name | title_case}}::LOGGER).to have_received(:info).with(
          /Processing.*test.*test-context/
        )
      end
    end
    
    describe '#multiply_by_two' do
      it 'multiplies positive numbers' do
        value = 5
        expected = 10
        
        result = service.multiply_by_two(value)
        
        expect(result).to eq(expected)
      end
      
      it 'multiplies zero' do
        value = 0
        expected = 0
        
        result = service.multiply_by_two(value)
        
        expect(result).to eq(expected)
      end
      
      it 'multiplies negative numbers' do
        value = -3
        expected = -6
        
        result = service.multiply_by_two(value)
        
        expect(result).to eq(expected)
      end
      
      it 'multiplies large numbers' do
        value = 1_000_000
        expected = 2_000_000
        
        result = service.multiply_by_two(value)
        
        expect(result).to eq(expected)
      end
      
      it 'multiplies floating point numbers' do
        value = 2.5
        expected = 5.0
        
        result = service.multiply_by_two(value)
        
        expect(result).to eq(expected)
      end
      
      it 'logs multiplication information' do
        allow({{package_name | title_case}}::LOGGER).to receive(:info)
        
        value = 5
        
        service.multiply_by_two(value)
        
        expect({{package_name | title_case}}::LOGGER).to have_received(:info).with(
          /Multiplying.*5/
        )
      end
    end
  end
  
  describe 'convenience methods' do
    describe '.process' do
      it 'works as a convenience method' do
        input = 'hello'
        context = 'test-context'
        expected = 'HELLO'
        
        result = {{package_name | title_case}}.process(input, context)
        
        expect(result).to eq(expected)
      end
    end
    
    describe '.multiply_by_two' do
      it 'works as a convenience method' do
        value = 5
        expected = 10
        
        result = {{package_name | title_case}}.multiply_by_two(value)
        
        expect(result).to eq(expected)
      end
    end
  end
  
  describe 'logging' do
    it 'has a properly configured logger' do
      expect({{package_name | title_case}}::LOGGER).to be_a(Logger)
      expect({{package_name | title_case}}::LOGGER.name).to eq('{{package_name}}')
    end
    
    it 'allows logger level configuration' do
      original_level = {{package_name | title_case}}::LOGGER.level
      
      begin
        {{package_name | title_case}}::LOGGER.level = Logger::DEBUG
        expect({{package_name | title_case}}::LOGGER.level).to eq(Logger::DEBUG)
        
        {{package_name | title_case}}::LOGGER.level = Logger::WARN
        expect({{package_name | title_case}}::LOGGER.level).to eq(Logger::WARN)
      ensure
        {{package_name | title_case}}::LOGGER.level = original_level
      end
    end
  end
  
  describe 'module structure' do
    it 'defines the Service class' do
      expect({{package_name | title_case}}::Service).to be_a(Class)
    end
    
    it 'defines factory methods' do
      expect({{package_name | title_case}}).to respond_to(:create_service)
      expect({{package_name | title_case}}).to respond_to(:process)
      expect({{package_name | title_case}}).to respond_to(:multiply_by_two)
    end
  end
end
