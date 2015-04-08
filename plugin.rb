# name: Hourly Backup
# about: Schedule hourly backup for Discourse
# version: 0.2
# authors: Frédéric Malo
# Many thanks to Régis Hanol ! https://meta.discourse.org/t/hourly-backup-only-if-something-has-changed/27274/12


after_initialize do
  module ::HourlyBackup
    class BackupJob < ::Jobs::Scheduled
      every 1.hour
      sidekiq_options retry: false

      def has_something_changed_since?(date=1.hour.ago)
        [User, Post, Topic].each do |klass|   
          return true if klass.where("created_at >= :date OR updated_at >= :date", date: date).exists?
        end
        false
      end

      def execute(args)
        #return unless SiteSetting.backup_daily?
        return unless has_something_changed_since?
        Jobs.enqueue_in(rand(4), :create_daily_backup) 
      end
    end
  end
end