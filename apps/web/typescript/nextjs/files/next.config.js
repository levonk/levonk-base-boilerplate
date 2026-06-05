/** @type {import('next').NextConfig} */
import { withJobAideNextConfig } from '@job-aide/tools-platform-next-config';

const nextConfig = withJobAideNextConfig({
  // Next.js 16: enable Cache Components globally
  cacheComponents: true,
  // Next.js 16: Turbopack is default; options at top-level
  turbopack: {},
  // Exporting static images in templates; keep unoptimized for boilerplate portability
  images: {
    unoptimized: true,
  },
  // Custom build output directory
  distDir: 'dist',
});

export default nextConfig;
