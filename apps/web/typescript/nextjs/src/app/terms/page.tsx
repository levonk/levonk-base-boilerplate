'use cache';

import { Suspense } from 'react';

export const metadata = {
  title: 'Terms of Service',
  description: 'Example Terms of Service page template',
};

export default function TermsPage() {
  return (
    <Suspense fallback={null}>
      <main className="mx-auto max-w-4xl px-6 py-16">
        <h1 className="text-4xl font-semibold tracking-tight">Terms of Service</h1>
        <p className="mt-4 text-gray-600">
          This is an example Terms of Service template. Replace with your organizations legal terms
          and conditions. Nothing here constitutes legal advice.
        </p>

        <section className="mt-10 space-y-4 text-gray-700">
          <h2 className="text-2xl font-medium">1. Use of Service</h2>
          <p>Provide permitted uses, restrictions, and acceptable use policies.</p>

          <h2 className="pt-6 text-2xl font-medium">2. Accounts & Security</h2>
          <p>Outline account responsibilities, security expectations, and notices.</p>

          <h2 className="pt-6 text-2xl font-medium">3. Billing & Payments</h2>
          <p>Summarize plans, billing cycles, refunds, and charge disputes.</p>

          <h2 className="pt-6 text-2xl font-medium">4. Liability & Warranty</h2>
          <p>Describe limitations of liability and warranty disclaimers.</p>

          <h2 className="pt-6 text-2xl font-medium">5. Changes to Terms</h2>
          <p>Explain how updates are communicated and when they take effect.</p>
        </section>
      </main>
    </Suspense>
  );
}
