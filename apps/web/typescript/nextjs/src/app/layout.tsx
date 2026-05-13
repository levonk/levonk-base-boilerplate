import "./globals.css";

export const metadata = {
  title: "Next.js App",
  description: "Next.js 16 App Router boilerplate",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
