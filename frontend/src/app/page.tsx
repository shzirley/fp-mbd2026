import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/ui/Button";

export default function LandingPage() {
  const dummyMovies = [
    { id: 1, title: "Garuda Merah", genre: "Action, Adventure", rating: "13+", img: "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3" },
    { id: 2, title: "Pulau Hantu", genre: "Horror, Thriller", rating: "17+", img: "https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3" },
    { id: 3, title: "Mega Force", genre: "Action, Superhero", rating: "13+", img: "https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3" },
    { id: 4, title: "Cinta di Ujung Senja", genre: "Drama, Romance", rating: "13+", img: "https://images.unsplash.com/photo-1485846234645-a62644f84728?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3" },
  ];

  return (
    <div className="min-h-screen bg-brand-bg text-brand-text flex flex-col">
      {/* Navbar */}
      <nav className="w-full border-b border-brand-border/50 bg-brand-bg/80 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
          <Link href="/" className="inline-flex items-center gap-2">
            <Image src="/images/logo.png" alt="Cinetrack Logo" width={150} height={32} className="object-contain" />
          </Link>
          
          <div className="flex items-center gap-4">
            <Link href="/login">
              <Button variant="outline" className="hidden sm:flex">Sign In</Button>
            </Link>
            <Link href="/register">
              <Button>Get Started</Button>
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="flex-grow">
        <section className="relative w-full py-20 lg:py-32 overflow-hidden flex items-center justify-center">
          {/* Background effects */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-brand-neon-pink/10 rounded-full blur-[120px] -z-10 pointer-events-none" />
          <div className="absolute bottom-0 right-0 w-[600px] h-[600px] bg-brand-neon-blue/10 rounded-full blur-[100px] -z-10 pointer-events-none" />
          
          <div className="max-w-4xl mx-auto px-4 text-center z-10">
            <h1 className="text-5xl md:text-7xl font-extrabold text-white tracking-tight mb-8">
              Experience Cinema Like <br />
              <span className="text-glow-pink text-brand-neon-pink">Never Before.</span>
            </h1>
            <p className="text-xl text-brand-text-muted mb-10 max-w-2xl mx-auto leading-relaxed">
              Book tickets, unlock premium VIP rewards, and immerse yourself in the magic of movies with Cinetrack's seamless ticketing platform.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link href="/register">
                <Button className="px-8 py-4 text-lg">Browse Movies</Button>
              </Link>
            </div>
          </div>
        </section>

        {/* Now Showing Section */}
        <section className="py-20 bg-brand-card/50 border-t border-brand-border/30">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-end mb-12">
              <div>
                <h2 className="text-3xl font-bold text-white mb-2">Now Showing</h2>
                <p className="text-brand-text-muted">Catch the latest blockbusters in theaters today.</p>
              </div>
              <Link href="/login" className="hidden sm:block text-brand-neon-pink hover:text-brand-neon-pink-hover font-medium">
                View All Schedule →
              </Link>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
              {dummyMovies.map((movie) => (
                <div key={movie.id} className="group relative rounded-2xl overflow-hidden glass border border-brand-border transition-transform hover:-translate-y-2 hover:shadow-[0_10px_30px_rgba(0,229,255,0.15)]">
                  <div className="aspect-[2/3] relative w-full overflow-hidden">
                    <img 
                      src={movie.img} 
                      alt={movie.title}
                      className="object-cover w-full h-full transition-transform duration-500 group-hover:scale-110 opacity-80 group-hover:opacity-100"
                    />
                    <div className="absolute top-3 right-3 bg-brand-bg/80 backdrop-blur-md px-2 py-1 rounded text-xs font-bold text-white border border-brand-border">
                      {movie.rating}
                    </div>
                  </div>
                  <div className="p-5">
                    <h3 className="text-lg font-bold text-white mb-1 truncate">{movie.title}</h3>
                    <p className="text-sm text-brand-text-muted mb-4">{movie.genre}</p>
                    <Link href="/login" className="block w-full">
                      <Button variant="outline" fullWidth className="border-brand-neon-blue/50 text-brand-neon-blue hover:bg-brand-neon-blue/10">
                        Get Tickets
                      </Button>
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="w-full border-t border-brand-border bg-brand-bg py-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row justify-between items-center gap-4">
          <div className="flex items-center gap-2">
            <Image src="/images/logo.png" alt="Cinetrack Logo" width={120} height={26} className="object-contain" />
          </div>
          <p className="text-brand-text-muted text-sm">
            &copy; 2026 Cinetrack. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
