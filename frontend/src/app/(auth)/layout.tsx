import Image from "next/image";
import Link from "next/link";

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen flex bg-brand-bg text-brand-text">
      {/* Left side: Background Image & Branding */}
      <div className="hidden lg:flex lg:w-1/2 relative flex-col justify-end p-12">
        <Image
          src="/images/bg-cinema.png"
          alt="Cinema background"
          fill
          className="object-cover object-center absolute inset-0 z-0 opacity-80"
          priority
        />
        {/* Dark gradient overlay at the bottom for text readability */}
        <div className="absolute inset-0 bg-gradient-to-t from-brand-bg/90 via-brand-bg/40 to-transparent z-10" />
        
        <div className="relative z-20 max-w-lg">
          <Link href="/" className="inline-flex items-center gap-2 mb-6">
            <Image src="/images/logo.png" alt="Cinetrack Logo" width={180} height={40} className="object-contain" />
          </Link>
          <h1 className="text-4xl font-bold text-white mb-4">
            Immersive Operations.
          </h1>
          <p className="text-brand-text-muted text-lg">
            Precision ticketing and theater management designed for the premium cinema experience.
          </p>
        </div>
      </div>

      {/* Right side: Auth Form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center p-6 sm:p-12">
        <div className="w-full max-w-md">
          {/* Mobile branding */}
          <div className="lg:hidden flex items-center justify-center gap-2 mb-8">
            <Image src="/images/logo.png" alt="Cinetrack Logo" width={160} height={36} className="object-contain" />
          </div>
          
          {children}
        </div>
      </div>
    </div>
  );
}
