module InstaCollage
  class ImageLoader
    include Celluloid

    POOL_SIZE = 25

    def download(url)
      path = "tmp/#{Time.now.to_f}.#{url.split('/').last}"
      `curl #{url} > #{path}`
      path
    end

    class << self
      def download_images(images)
        pool = self.pool(size: POOL_SIZE)
        futures = images.map { |i| pool.future.download(i) }
        futures.map(&:value)
      end
    end
  end
end

