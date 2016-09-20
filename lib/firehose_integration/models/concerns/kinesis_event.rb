module FirehoseIntegration
  module KinesisEvent
    extend ActiveSupport::Concern

    MAX_REDSHIFT_STRING_SIZE = 65535

    module ClassMethods
      def firehose_integratable
        after_commit :send_kinesis_event, unless: Proc.new { |instance| instance.try(:skip_kinesis_event) || ENV['SKIP_KINESIS_EVENTS'] == 'true' }

        begin
          include "#{self.model_name.name}KinesisSerializer".constantize
        rescue
        end
      end

      def kinesis_stream_name
        raise(NoMethodError, "Model must define class method kinesis_stream_name")
      end
    end

    included do

      def to_kinesis
        raise(NoMethodError, "Model must define instance method to_kinesis")
      end

      def prepare_for_redshift(field)
        if field.present?
          if field.is_a? Array
            output = []
            field.each do |f|
              output << massage_data_for_redshift(f)
            end
            return output.join("|")
          end
        end
      end

      def massage_data_for_redshift field
        if field.is_a? String
          output = escape_string_for_redshift(field).truncate(MAX_REDSHIFT_STRING_SIZE)
          Rails.logger.info "Redshift data has been truncated due to length: #{output.truncate(50)}" if output.size == MAX_REDSHIFT_STRING_SIZE
          output
        else
          field
        end
      end

      def escape_string_for_redshift field
        return field unless field.is_a? String
        output = field
        {
          '\n' => '\\n',
          '\r' => '\\r',
          '\|' => '&verbar;'
        }.each do |pattern, replacement|
          output = output.gsub(Regexp.new(pattern), replacement)
        end
        output.force_encoding("utf-8")
      end


      def send_kinesis_event
        begin
          KinesisJob.perform_later(self.class.kinesis_stream_name, self.to_kinesis)
          self.kinesis_extra_serialization if self.methods.include? :kinesis_extra_serialization
        rescue
          Rails.logger.error("Failed to queue #{self.class.kinesis_stream_name} data: #{self.to_kinesis}")
        end
      end
    end
  end
end
ActiveRecord::Base.send :include, FirehoseIntegration::KinesisEvent
