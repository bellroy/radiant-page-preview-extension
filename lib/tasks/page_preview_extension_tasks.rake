namespace :radiant do
  namespace :extensions do
    namespace :page_preview do
      
      desc "Runs the migration of the Page Preview extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          PagePreviewExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          PagePreviewExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Page Preview to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[PagePreviewExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(PagePreviewExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
