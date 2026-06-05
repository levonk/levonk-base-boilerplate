#!/usr/bin/env ts-node

// Optimize and convert your image assets

import imagemin from 'imagemin';
import imageminMozjpeg from 'imagemin-mozjpeg';
import imageminPngquant from 'imagemin-pngquant';
import imageminWebp from 'imagemin-webp';
import { globby } from 'globby';

async function run(): Promise<void> {
  // Discover all JPG and PNG files under public/images
  const files: string[] = await globby(['public/images/**/*.{jpg,png}']);
	const destinationPath: string = 'dist/images/';

  // Optimize and convert
  await imagemin(files, {
    destination: destinationPath,
    plugins: [
      imageminMozjpeg({ quality: 80 }),
      imageminPngquant({ quality: [0.6, 0.8] }),
      imageminWebp({ quality: 80 })
    ]
  });

  console.log('✅ Images optimized and written to ', destinationPath);
}

run().catch((error: unknown) => {
  console.error('❌ Image optimization failed:', error);
  process.exit(1);
});
