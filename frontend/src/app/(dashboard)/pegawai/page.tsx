"use client";

import { useEffect, useState } from "react";
import Cookies from "js-cookie";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { 
  LayoutDashboard, MapPin, Film, CalendarDays, Coffee, Users, ReceiptText, 
  Search, Bell, Settings, TrendingUp, TrendingDown, Plus, AlertTriangle
} from "lucide-react";
import { BarChart, Bar, XAxis, Tooltip, ResponsiveContainer, Cell, CartesianGrid } from "recharts";

// Mock Data for the chart
const revenueData = [
  { name: "Mon", value: 3000 },
  { name: "Tue", value: 4500 },
  { name: "Wed", value: 4000 },
  { name: "Thu", value: 5000 },
  { name: "Fri", value: 8500 },
  { name: "Sat", value: 12000 },
  { name: "Sun", value: 9000 },
];

export default function PegawaiDashboard() {
  const router = useRouter();
  const [user, setUser] = useState<any>(null);
  const [activeTab, setActiveTab] = useState("dashboard");

  useEffect(() => {
    const userInfo = Cookies.get("cinetrack_user");
    if (!userInfo) {
      router.push("/login");
      return;
    }
    try {
      const parsedUser = JSON.parse(userInfo);
      if (parsedUser.role !== "pegawai") {
        router.push("/login");
        return;
      }
      setUser(parsedUser);
    } catch (e) {
      router.push("/login");
    }
  }, [router]);

  const formatRupiah = (number: number) => {
    return new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", minimumFractionDigits: 0 }).format(number);
  };

  if (!user) return <div className="min-h-screen bg-brand-bg flex items-center justify-center text-white">Loading...</div>;

  return (
    <div className="min-h-screen bg-[#0B1326] text-white flex overflow-hidden">
      {/* SIDEBAR */}
      <aside className="w-64 border-r border-[#1E293B] bg-[#0A101D] flex flex-col h-screen sticky top-0 hidden md:flex">
        <div className="h-20 flex items-center px-6 border-b border-[#1E293B]">
          <div className="relative w-48 h-14">
            <Image src="/images/logo.png" alt="CineTrack Logo" fill className="object-contain" priority />
          </div>
        </div>
        <nav className="flex-1 py-6 px-4 space-y-1 overflow-y-auto">
          <SidebarItem icon={LayoutDashboard} label="Dashboard" isActive={activeTab === "dashboard"} onClick={() => setActiveTab("dashboard")} />
          <SidebarItem icon={MapPin} label="Branches" isActive={activeTab === "branches"} onClick={() => setActiveTab("branches")} />
          <SidebarItem icon={Film} label="Movies" isActive={activeTab === "movies"} onClick={() => setActiveTab("movies")} />
          <SidebarItem icon={CalendarDays} label="Schedules" isActive={activeTab === "schedules"} onClick={() => setActiveTab("schedules")} />
          <SidebarItem icon={Coffee} label="F&B" isActive={activeTab === "fb"} onClick={() => setActiveTab("fb")} />
          <SidebarItem icon={Users} label="HR / Settings" isActive={activeTab === "hr"} onClick={() => setActiveTab("hr")} />
          <SidebarItem icon={ReceiptText} label="Transactions" isActive={activeTab === "transactions"} onClick={() => setActiveTab("transactions")} />
        </nav>
        <div className="p-4 border-t border-[#1E293B]">
          <div className="flex items-center gap-3 p-2 rounded-xl hover:bg-white/5 cursor-pointer transition-colors" onClick={() => {
            Cookies.remove("cinetrack_token");
            Cookies.remove("cinetrack_user");
            router.push("/login");
          }}>
            <div className="w-10 h-10 rounded-full bg-brand-neon-pink flex items-center justify-center font-bold text-white shadow-lg shadow-brand-neon-pink/20">
              {user.name.substring(0,2).toUpperCase()}
            </div>
            <div className="overflow-hidden">
              <p className="text-sm font-semibold truncate">{user.name}</p>
              <p className="text-xs text-gray-400 truncate">System Administrator</p>
            </div>
          </div>
        </div>
      </aside>

      {/* MAIN CONTENT */}
      <main className="flex-1 flex flex-col h-screen overflow-y-auto">
        <header className="h-20 min-h-[5rem] flex items-center justify-between px-8 border-b border-[#1E293B] bg-[#0A101D]/50 backdrop-blur-md sticky top-0 z-10">
          <h2 className="text-lg font-semibold text-gray-200 capitalize">{activeTab}</h2>
          <div className="flex items-center gap-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
              <input type="text" placeholder="Global search..." className="bg-[#151B2B] border border-[#2A3441] text-sm rounded-full pl-10 pr-4 py-2 focus:outline-none focus:border-brand-neon-blue transition-colors w-64 text-gray-200" />
            </div>
            <div className="flex items-center gap-4 text-gray-400">
              <button className="hover:text-white transition-colors"><Bell size={20} /></button>
              <button className="hover:text-white transition-colors"><Settings size={20} /></button>
            </div>
          </div>
        </header>

        <div className="p-8 max-w-7xl mx-auto w-full">
          {activeTab === "dashboard" && <DashboardTab formatRupiah={formatRupiah} />}
          {activeTab === "movies" && <MoviesTab />}
          {activeTab === "schedules" && <SchedulesTab formatRupiah={formatRupiah} />}
          {activeTab === "fb" && <FBTab formatRupiah={formatRupiah} />}
          {activeTab === "transactions" && <TransactionsTab formatRupiah={formatRupiah} />}
          {activeTab === "hr" && <HRTab />}
          {activeTab === "branches" && <div className="text-center py-20 text-gray-400">Branches Management (Under Construction)</div>}
        </div>
      </main>
    </div>
  );
}

// --- SIDEBAR ITEM COMPONENT ---
function SidebarItem({ icon: Icon, label, isActive, onClick }: { icon: any, label: string, isActive: boolean, onClick: () => void }) {
  return (
    <button 
      onClick={onClick}
      className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-all ${
        isActive 
          ? "bg-brand-neon-pink/15 text-brand-neon-pink shadow-inner" 
          : "text-gray-400 hover:text-white hover:bg-white/5"
      }`}
    >
      <Icon size={20} />
      {label}
    </button>
  );
}

// --- TAB COMPONENTS ---

function DashboardTab({ formatRupiah }: { formatRupiah: (n: number) => string }) {
  const [stats, setStats] = useState({ totalPendapatan: 0, tiketTerjual: 0, totalKantin: 0, activeMovies: 0 });

  useEffect(() => {
    fetch("http://localhost:5000/api/dashboard/stats")
      .then(res => res.json())
      .then(data => { if (data.success && data.data) setStats(data.data); });
  }, []);

  return (
    <>
      <div className="mb-8">
        <h1 className="text-4xl font-bold text-white mb-2">Executive Dashboard</h1>
        <p className="text-gray-400">Real-time cinema network performance and analytics.</p>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <MetricCard title="Daily Sales" value={formatRupiah(stats.totalPendapatan)} icon={ReceiptText} trend="+12.5%" color="bg-brand-neon-blue" />
        <MetricCard title="Tickets Sold" value={stats.tiketTerjual.toLocaleString()} icon={ReceiptText} trend="+8.2%" color="bg-amber-400" />
        <MetricCard title="F&B Revenue" value={formatRupiah(stats.totalKantin)} icon={Coffee} trend="-2.4%" color="bg-emerald-400" isDown />
        <MetricCard title="Active Movies" value={stats.activeMovies.toString()} icon={Film} color="bg-brand-neon-pink" />
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6 h-80">
             <h3 className="text-xs font-bold text-gray-400 tracking-widest uppercase mb-6">REVENUE TRAJECTORY (24H)</h3>
             <ResponsiveContainer width="100%" height="80%">
                <BarChart data={revenueData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#1F2937" vertical={false} />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#6B7280', fontSize: 12 }} dy={10} />
                  <Tooltip cursor={{ fill: '#1A2333' }} contentStyle={{ backgroundColor: '#0A101D', borderColor: '#1F2937', borderRadius: '8px', color: '#fff' }} />
                  <Bar dataKey="value" radius={[4, 4, 4, 4]}>
                    {revenueData.map((e, i) => <Cell key={i} fill={e.name === 'Sat' ? '#E11D48' : '#374151'} />)}
                  </Bar>
                </BarChart>
             </ResponsiveContainer>
          </div>
        </div>
        <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6">
          <h3 className="text-lg font-bold text-white mb-4">Quick Stats</h3>
          <p className="text-sm text-gray-400">Backend API is fully connected to MySQL Functions and Views.</p>
        </div>
      </div>
    </>
  );
}

function MetricCard({ title, value, icon: Icon, trend, color, isDown }: any) {
  return (
    <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6 relative overflow-hidden group">
      <div className={`absolute top-0 left-0 w-full h-1 ${color} opacity-50`}></div>
      <div className="flex justify-between items-start mb-4">
        <div className="w-10 h-10 rounded-lg bg-[#1F2937] flex items-center justify-center text-white"><Icon size={20} /></div>
        {trend && (
          <div className={`flex items-center gap-1 text-xs font-medium ${isDown ? 'text-rose-400' : 'text-emerald-400'}`}>
            {trend} {isDown ? <TrendingDown size={14} /> : <TrendingUp size={14} />}
          </div>
        )}
      </div>
      <p className="text-gray-400 text-sm mb-1">{title}</p>
      <h3 className="text-2xl font-bold text-white">{value}</h3>
    </div>
  );
}

function MoviesTab() {
  const [movies, setMovies] = useState([]);
  useEffect(() => {
    fetch("http://localhost:5000/api/pegawai/movies").then(r => r.json()).then(d => { if(d.success) setMovies(d.data); });
  }, []);

  return (
    <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6">
      <h2 className="text-xl font-bold mb-4 flex items-center gap-2"><Film className="text-brand-neon-pink" /> Now Showing (vw_daftar_film)</h2>
      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm text-gray-300">
          <thead className="text-xs text-gray-400 uppercase bg-[#1A2333]">
            <tr><th className="px-4 py-3 rounded-tl-lg">Judul Film</th><th className="px-4 py-3">Genre</th><th className="px-4 py-3 rounded-tr-lg">Status</th></tr>
          </thead>
          <tbody>
            {movies.map((m: any, i) => (
              <tr key={i} className="border-b border-[#1F2937] hover:bg-white/5">
                <td className="px-4 py-3 font-medium text-white">{m.judul_film}</td>
                <td className="px-4 py-3">{m.genre}</td>
                <td className="px-4 py-3"><span className="bg-emerald-400/10 text-emerald-400 px-2 py-1 rounded text-xs">{m.status}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function SchedulesTab({ formatRupiah }: any) {
  const [schedules, setSchedules] = useState([]);
  
  // Form states
  const [tanggal, setTanggal] = useState("");
  const [hargaDasar, setHargaDasar] = useState("");
  const [idStudio, setIdStudio] = useState("");
  const [idFilm, setIdFilm] = useState("");

  const fetchSchedules = () => {
    fetch("http://localhost:5000/api/pegawai/schedules").then(r => r.json()).then(d => { if(d.success) setSchedules(d.data); });
  };

  useEffect(() => {
    fetchSchedules();
  }, []);

  const handleAddMidnight = async (e: any) => {
    e.preventDefault();
    if (!tanggal || !hargaDasar || !idStudio || !idFilm) return alert("Harap isi semua kolom!");

    const res = await fetch("http://localhost:5000/api/pegawai/schedules/midnight", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ tanggal, harga_dasar: parseInt(hargaDasar), id_studio: idStudio, id_film: idFilm })
    });
    const data = await res.json();
    alert(data.message);
    if (data.success) {
      setTanggal(""); setHargaDasar(""); setIdStudio(""); setIdFilm("");
      fetchSchedules(); // refresh data
    }
  };

  return (
    <div className="space-y-6">
      {/* FORM TAMBAH JADWAL */}
      <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6">
        <h2 className="text-xl font-bold mb-4 flex items-center gap-2"><CalendarDays className="text-brand-neon-blue" /> Tambah Midnight Show</h2>
        <form onSubmit={handleAddMidnight} className="grid grid-cols-1 md:grid-cols-5 gap-4 items-end">
          <div>
            <label className="block text-xs text-gray-400 mb-1">Tanggal</label>
            <input type="date" value={tanggal} onChange={e => setTanggal(e.target.value)} className="w-full bg-[#1A2333] border border-[#2A3441] rounded-lg px-3 py-2 text-white focus:outline-none focus:border-brand-neon-blue" />
          </div>
          <div>
            <label className="block text-xs text-gray-400 mb-1">Harga Dasar (Rp)</label>
            <input type="number" placeholder="85000" value={hargaDasar} onChange={e => setHargaDasar(e.target.value)} className="w-full bg-[#1A2333] border border-[#2A3441] rounded-lg px-3 py-2 text-white focus:outline-none focus:border-brand-neon-blue" />
          </div>
          <div>
            <label className="block text-xs text-gray-400 mb-1">ID Studio</label>
            <input type="text" placeholder="ST0001" value={idStudio} onChange={e => setIdStudio(e.target.value)} className="w-full bg-[#1A2333] border border-[#2A3441] rounded-lg px-3 py-2 text-white focus:outline-none focus:border-brand-neon-blue uppercase" />
          </div>
          <div>
            <label className="block text-xs text-gray-400 mb-1">ID Film</label>
            <input type="text" placeholder="FM0001" value={idFilm} onChange={e => setIdFilm(e.target.value)} className="w-full bg-[#1A2333] border border-[#2A3441] rounded-lg px-3 py-2 text-white focus:outline-none focus:border-brand-neon-blue uppercase" />
          </div>
          <button type="submit" className="bg-brand-neon-blue hover:bg-brand-neon-blue-hover text-white px-4 py-2 rounded-lg text-sm font-bold flex items-center justify-center gap-2 transition-colors h-[42px]">
            <Plus size={16} /> Tambah
          </button>
        </form>
      </div>

      {/* TABEL JADWAL */}
      <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6">
        <h2 className="text-xl font-bold mb-4">Jadwal Tayang (vw_jadwal_tayang)</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-gray-300">
            <thead className="text-xs text-gray-400 uppercase bg-[#1A2333]">
              <tr><th className="px-4 py-3 rounded-tl-lg">Waktu</th><th className="px-4 py-3">Film</th><th className="px-4 py-3">Studio</th><th className="px-4 py-3 rounded-tr-lg">Harga Dasar</th></tr>
            </thead>
            <tbody>
              {schedules.map((s: any, i) => (
                <tr key={i} className="border-b border-[#1F2937] hover:bg-white/5">
                  <td className="px-4 py-3">{new Date(s.waktu).toLocaleString("id-ID")}</td>
                  <td className="px-4 py-3 font-medium text-white">{s.film}</td>
                  <td className="px-4 py-3">{s.kelas_studio} ({s.cabang})</td>
                  <td className="px-4 py-3">{formatRupiah(s.harga_dasar)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function FBTab({ formatRupiah }: any) {
  const [fbStats, setFbStats] = useState([]);
  
  // Form states
  const [idProduk, setIdProduk] = useState("");
  const [jumlah, setJumlah] = useState("");

  const fetchFB = () => {
    fetch("http://localhost:5000/api/pegawai/fb").then(r => r.json()).then(d => { if(d.success) setFbStats(d.data); });
  };

  useEffect(() => { fetchFB(); }, []);

  const handleRestock = async (e: any) => {
    e.preventDefault();
    if (!idProduk || !jumlah) return alert("Harap isi semua kolom!");

    const res = await fetch("http://localhost:5000/api/pegawai/fb/restock", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id_produk: idProduk, jumlah_tambah: parseInt(jumlah) })
    });
    const data = await res.json();
    alert(data.message);
    if (data.success) {
      setIdProduk(""); setJumlah("");
      fetchFB();
    }
  };

  return (
    <div className="space-y-6">
      <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6 max-w-2xl">
        <h2 className="text-xl font-bold mb-4 flex items-center gap-2"><Coffee className="text-amber-400" /> Restock Item Kantin</h2>
        <form onSubmit={handleRestock} className="flex gap-4 items-end">
          <div className="flex-1">
            <label className="block text-xs text-gray-400 mb-1">ID Produk</label>
            <input type="text" placeholder="PK0001" value={idProduk} onChange={e => setIdProduk(e.target.value)} className="w-full bg-[#1A2333] border border-[#2A3441] rounded-lg px-3 py-2 text-white focus:outline-none focus:border-amber-400 uppercase" />
          </div>
          <div className="flex-1">
            <label className="block text-xs text-gray-400 mb-1">Jumlah Tambah</label>
            <input type="number" placeholder="50" value={jumlah} onChange={e => setJumlah(e.target.value)} className="w-full bg-[#1A2333] border border-[#2A3441] rounded-lg px-3 py-2 text-white focus:outline-none focus:border-amber-400" />
          </div>
          <button type="submit" className="bg-amber-400 hover:bg-amber-500 text-black px-6 py-2 rounded-lg text-sm font-bold flex items-center gap-2 transition-colors h-[42px]">
            <Plus size={16} /> Restock
          </button>
        </form>
      </div>

      <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6">
        <h2 className="text-xl font-bold mb-4">F&B Sales (vw_rekap_kantin)</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-gray-300">
            <thead className="text-xs text-gray-400 uppercase bg-[#1A2333]">
              <tr><th className="px-4 py-3 rounded-tl-lg">Kategori</th><th className="px-4 py-3">Produk</th><th className="px-4 py-3">Terjual</th><th className="px-4 py-3 rounded-tr-lg">Pendapatan</th></tr>
            </thead>
            <tbody>
              {fbStats.map((f: any, i) => (
                <tr key={i} className="border-b border-[#1F2937] hover:bg-white/5">
                  <td className="px-4 py-3">{f.kategori}</td>
                  <td className="px-4 py-3 font-medium text-white">{f.produk}</td>
                  <td className="px-4 py-3 text-amber-400">{f.total_terjual}</td>
                  <td className="px-4 py-3">{formatRupiah(f.total_pendapatan)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function TransactionsTab({ formatRupiah }: any) {
  const [trx, setTrx] = useState([]);
  useEffect(() => {
    fetch("http://localhost:5000/api/pegawai/transactions").then(r => r.json()).then(d => { if(d.success) setTrx(d.data); });
  }, []);

  return (
    <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6">
      <h2 className="text-xl font-bold mb-4 flex items-center gap-2"><ReceiptText className="text-emerald-400" /> High-Value Transactions (vw_transaksi_tinggi)</h2>
      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm text-gray-300">
          <thead className="text-xs text-gray-400 uppercase bg-[#1A2333]">
            <tr><th className="px-4 py-3 rounded-tl-lg">ID</th><th className="px-4 py-3">Pelanggan</th><th className="px-4 py-3">Tanggal</th><th className="px-4 py-3">Metode</th><th className="px-4 py-3 rounded-tr-lg">Total</th></tr>
          </thead>
          <tbody>
            {trx.map((t: any, i) => (
              <tr key={i} className="border-b border-[#1F2937] hover:bg-white/5">
                <td className="px-4 py-3 font-mono">{t.id_transaksi}</td>
                <td className="px-4 py-3 font-medium text-white">{t.pelanggan}</td>
                <td className="px-4 py-3">{new Date(t.tanggal).toLocaleString("id-ID")}</td>
                <td className="px-4 py-3">{t.metode_bayar}</td>
                <td className="px-4 py-3 text-emerald-400 font-bold">{formatRupiah(t.total_tagihan)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function HRTab() {
  const [persentase, setPersentase] = useState("");

  const handleInflasi = async (e: any) => {
    e.preventDefault();
    if (!persentase) return alert("Harap isi persentase!");

    const res = await fetch("http://localhost:5000/api/pegawai/inflation", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ persentase: parseFloat(persentase) })
    });
    const data = await res.json();
    alert(data.message);
    if(data.success) setPersentase("");
  };

  return (
    <div className="bg-[#111827] border border-[#1F2937] rounded-2xl p-6 max-w-xl">
      <h2 className="text-xl font-bold mb-6 flex items-center gap-2"><Users className="text-brand-neon-pink" /> HR & Settings</h2>
      
      <div className="bg-rose-500/10 border border-rose-500/30 rounded-xl p-5">
        <div className="flex items-start gap-4">
          <div className="bg-rose-500/20 p-3 rounded-full text-rose-500">
            <AlertTriangle size={24} />
          </div>
          <div className="w-full">
            <h3 className="text-white font-bold mb-1">Apply Global Inflation</h3>
            <p className="text-sm text-gray-400 mb-4">Execute stored procedure <code>NaikkanHargaInflasi</code> to dynamically increase all ticket and F&B base prices.</p>
            
            <form onSubmit={handleInflasi} className="flex gap-3 items-end">
              <div className="flex-1">
                <label className="block text-xs text-rose-400 mb-1">Persentase Kenaikan (%)</label>
                <input 
                  type="number" step="0.1" placeholder="Misal: 5.0" 
                  value={persentase} onChange={e => setPersentase(e.target.value)} 
                  className="w-full bg-[#1A2333] border border-rose-500/30 rounded-lg px-3 py-2 text-white focus:outline-none focus:border-rose-500" 
                />
              </div>
              <button type="submit" className="bg-rose-500 hover:bg-rose-600 text-white px-6 py-2 rounded-lg text-sm font-bold transition-colors h-[42px] whitespace-nowrap">
                Execute Procedure
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}
