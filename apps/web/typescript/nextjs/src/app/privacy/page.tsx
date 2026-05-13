'use cache';

import { Suspense } from 'react';

export const metadata = {
  title: 'Privacy Policy',
  description: 'Example Privacy Policy page template',
};

export default function PrivacyPage() {
  return (
    <Suspense fallback={null}>
      <main className="mx-auto max-w-4xl px-6 py-16">
        <h1 className="text-4xl font-semibold tracking-tight">Privacy Policy</h1>
        <p className="mt-4 text-gray-600">
          This is an example Privacy Policy template. Replace with your organizations privacy
          practices, data usage disclosures, and contact details. Nothing here constitutes legal
          advice.
        </p>

        <section className="mt-10 space-y-4 text-gray-700">
          <h2 className="text-2xl font-medium">1. Data We Collect</h2>
          <p>Describe categories of data collected and the purposes for collection.</p>

          <h2 className="pt-6 text-2xl font-medium">2. How We Use Data</h2>
          <p>
            Explain usage: service delivery, security, analytics, support, and legal obligations.
          </p>

          <h2 className="pt-6 text-2xl font-medium">3. Sharing & Transfers</h2>
          <p>List processors, subprocessors, and transfer safeguards (e.g., SCCs).</p>

          <h2 className="pt-6 text-2xl font-medium">4. Your Rights</h2>
          <p>Summarize access, deletion, correction, and portability rights where applicable.</p>

          <h2 className="pt-6 text-2xl font-medium">5. Contact</h2>
          <p>Provide a contact method for privacy inquiries and DSRs.</p>
        </section>
      </main>
    </Suspense>
  );
}
