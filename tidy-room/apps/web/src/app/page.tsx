'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import Link from 'next/link';
import {
  Sparkles,
  Home,
  Trophy,
  Star,
  CheckCircle2,
  Gamepad2,
  Users,
  Shield,
  ArrowRight,
  Zap
} from 'lucide-react';

// Generate random positions only on client side to avoid hydration mismatch
function useRandomPositions(count: number) {
  const [positions, setPositions] = useState<Array<{ left: number; top: number }>>([]);

  useEffect(() => {
    setPositions(
      Array.from({ length: count }, () => ({
        left: Math.random() * 100,
        top: Math.random() * 100,
      }))
    );
  }, [count]);

  return positions;
}

export default function LandingPage() {
  // Generate positions on client side only
  const bgParticlePositions = useRandomPositions(20);
  const sparklePositions = useRandomPositions(5);
  const ctaDecorationPositions = useRandomPositions(10);

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-indigo-900 to-blue-900 overflow-hidden">
      {/* Animated background elements */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        {bgParticlePositions.map((pos, i) => (
          <motion.div
            key={i}
            className="absolute w-2 h-2 bg-white/20 rounded-full"
            style={{
              left: `${pos.left}%`,
              top: `${pos.top}%`,
            }}
            animate={{
              y: [0, -30, 0],
              opacity: [0.2, 0.8, 0.2],
              scale: [1, 1.5, 1],
            }}
            transition={{
              duration: 3 + (i % 5) * 0.4,
              repeat: Infinity,
              delay: (i % 10) * 0.2,
            }}
          />
        ))}
      </div>

      {/* Navigation */}
      <nav className="relative z-10 flex items-center justify-between px-6 py-4 md:px-12">
        <motion.div
          className="flex items-center gap-2"
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5 }}
        >
          <div className="w-10 h-10 bg-gradient-to-br from-purple-400 to-pink-400 rounded-xl flex items-center justify-center">
            <Home className="w-6 h-6 text-white" />
          </div>
          <span className="text-xl font-bold text-white">Tidy Room</span>
        </motion.div>

        <motion.div
          className="flex items-center gap-4"
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5 }}
        >
          <Link
            href="/login"
            className="text-white/80 hover:text-white font-medium transition-colors"
          >
            Login
          </Link>
          <Link
            href="/register"
            className="bg-white text-purple-900 px-5 py-2 rounded-full font-semibold hover:bg-purple-100 transition-colors shadow-lg shadow-white/20"
          >
            Get Started
          </Link>
        </motion.div>
      </nav>

      {/* Hero Section */}
      <section className="relative z-10 container mx-auto px-6 pt-12 pb-20 md:pt-20">
        <div className="grid md:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <motion.div
            className="text-center md:text-left"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <motion.div
              className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-full mb-6"
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.2 }}
            >
              <Sparkles className="w-4 h-4 text-yellow-400" />
              <span className="text-white/90 text-sm font-medium">Making cleaning fun for kids!</span>
            </motion.div>

            <h1 className="text-4xl md:text-6xl font-extrabold text-white leading-tight mb-6">
              Transform Cleaning Into An{' '}
              <span className="bg-gradient-to-r from-yellow-400 via-pink-400 to-purple-400 bg-clip-text text-transparent">
                Adventure
              </span>
            </h1>

            <p className="text-lg text-white/70 mb-8 max-w-lg mx-auto md:mx-0">
              Watch your virtual room transform as you complete real-world cleaning tasks.
              Earn points, unlock decorations, and become a cleaning champion!
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center md:justify-start">
              <Link
                href="/register"
                className="group flex items-center justify-center gap-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white px-8 py-4 rounded-2xl font-bold text-lg shadow-2xl shadow-purple-500/30 hover:shadow-purple-500/50 hover:-translate-y-1 transition-all duration-300"
              >
                Start Your Journey
                <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </Link>
              <Link
                href="#features"
                className="flex items-center justify-center gap-2 bg-white/10 backdrop-blur-sm text-white px-8 py-4 rounded-2xl font-semibold hover:bg-white/20 transition-all duration-300"
              >
                Learn More
              </Link>
            </div>

            {/* Stats */}
            <motion.div
              className="flex items-center gap-8 mt-12 justify-center md:justify-start"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
            >
              <div className="text-center">
                <div className="text-3xl font-bold text-white">100+</div>
                <div className="text-sm text-white/60">Tasks Available</div>
              </div>
              <div className="w-px h-12 bg-white/20" />
              <div className="text-center">
                <div className="text-3xl font-bold text-white">20+</div>
                <div className="text-sm text-white/60">Decorations</div>
              </div>
              <div className="w-px h-12 bg-white/20" />
              <div className="text-center">
                <div className="text-3xl font-bold text-white">7</div>
                <div className="text-sm text-white/60">Room Themes</div>
              </div>
            </motion.div>
          </motion.div>

          {/* Right - Hero Illustration */}
          <motion.div
            className="relative"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <div className="relative w-full max-w-lg mx-auto">
              {/* Glowing background */}
              <div className="absolute inset-0 bg-gradient-to-br from-purple-500/30 to-pink-500/30 rounded-3xl blur-3xl" />

              {/* Room Preview Card */}
              <div className="relative bg-white/10 backdrop-blur-md rounded-3xl p-6 border border-white/20">
                {/* Room visualization */}
                <div className="aspect-video bg-gradient-to-br from-indigo-200 to-purple-200 rounded-2xl overflow-hidden relative">
                  {/* Room floor */}
                  <div className="absolute bottom-0 left-0 right-0 h-1/3 bg-gradient-to-t from-amber-100 to-amber-50" />

                  {/* Bed */}
                  <motion.div
                    className="absolute bottom-8 left-4 w-24 h-16 bg-gradient-to-b from-pink-300 to-pink-400 rounded-lg shadow-lg"
                    animate={{ y: [0, -2, 0] }}
                    transition={{ duration: 2, repeat: Infinity }}
                  >
                    <div className="absolute -top-2 left-2 right-2 h-4 bg-white rounded-t-lg" />
                  </motion.div>

                  {/* Desk */}
                  <motion.div
                    className="absolute bottom-8 right-4 w-20 h-12 bg-gradient-to-b from-amber-400 to-amber-500 rounded shadow-lg"
                    animate={{ y: [0, -2, 0] }}
                    transition={{ duration: 2, repeat: Infinity, delay: 0.5 }}
                  />

                  {/* Window */}
                  <div className="absolute top-4 left-1/2 -translate-x-1/2 w-16 h-16 bg-gradient-to-b from-sky-200 to-sky-300 rounded-lg border-4 border-white shadow-lg" />

                  {/* Sparkles when clean */}
                  {sparklePositions.map((pos, i) => (
                    <motion.div
                      key={i}
                      className="absolute text-yellow-400"
                      style={{
                        left: `${20 + pos.left * 0.6}%`,
                        top: `${20 + pos.top * 0.6}%`,
                      }}
                      animate={{
                        scale: [0, 1, 0],
                        opacity: [0, 1, 0],
                      }}
                      transition={{
                        duration: 1.5,
                        repeat: Infinity,
                        delay: i * 0.3,
                      }}
                    >
                      ✨
                    </motion.div>
                  ))}
                </div>

                {/* Stats bar */}
                <div className="mt-4 flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 bg-green-400 rounded-full flex items-center justify-center">
                      <CheckCircle2 className="w-5 h-5 text-white" />
                    </div>
                    <div>
                      <div className="text-white font-semibold">85% Clean</div>
                      <div className="text-white/60 text-xs">Great job!</div>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <Star className="w-5 h-5 text-yellow-400" />
                    <span className="text-white font-bold">1,250 pts</span>
                  </div>
                </div>
              </div>

              {/* Floating badges */}
              <motion.div
                className="absolute -top-4 -right-4 bg-gradient-to-r from-green-400 to-emerald-400 text-white px-4 py-2 rounded-full text-sm font-bold shadow-lg"
                animate={{ y: [0, -10, 0] }}
                transition={{ duration: 2, repeat: Infinity }}
              >
                🔥 7 Day Streak!
              </motion.div>

              <motion.div
                className="absolute -bottom-4 -left-4 bg-gradient-to-r from-yellow-400 to-orange-400 text-white px-4 py-2 rounded-full text-sm font-bold shadow-lg"
                animate={{ y: [0, -10, 0] }}
                transition={{ duration: 2, repeat: Infinity, delay: 0.5 }}
              >
                ⭐ Level 10
              </motion.div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="relative z-10 py-20 bg-white/5 backdrop-blur-sm">
        <div className="container mx-auto px-6">
          <motion.div
            className="text-center mb-16"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
          >
            <h2 className="text-3xl md:text-5xl font-bold text-white mb-4">
              Why Kids Love Tidy Room
            </h2>
            <p className="text-white/60 text-lg max-w-2xl mx-auto">
              We&apos;ve transformed boring chores into an exciting adventure
            </p>
          </motion.div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              {
                icon: <Gamepad2 className="w-8 h-8" />,
                title: "Gamified Experience",
                description: "Complete tasks, earn points, and level up like in your favorite games!",
                color: "from-purple-500 to-pink-500",
              },
              {
                icon: <Home className="w-8 h-8" />,
                title: "Virtual Room",
                description: "Watch your room transform from messy to pristine as you complete tasks.",
                color: "from-blue-500 to-cyan-500",
              },
              {
                icon: <Trophy className="w-8 h-8" />,
                title: "Rewards & Themes",
                description: "Unlock cool decorations and themes for your virtual room.",
                color: "from-yellow-500 to-orange-500",
              },
              {
                icon: <Users className="w-8 h-8" />,
                title: "Family Friendly",
                description: "Parents can assign tasks and track progress easily.",
                color: "from-green-500 to-emerald-500",
              },
            ].map((feature, i) => (
              <motion.div
                key={i}
                className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 border border-white/10 hover:bg-white/15 transition-all duration-300"
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
              >
                <div className={`w-14 h-14 bg-gradient-to-br ${feature.color} rounded-xl flex items-center justify-center text-white mb-4`}>
                  {feature.icon}
                </div>
                <h3 className="text-xl font-bold text-white mb-2">{feature.title}</h3>
                <p className="text-white/60">{feature.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="relative z-10 py-20">
        <div className="container mx-auto px-6">
          <motion.div
            className="text-center mb-16"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
          >
            <h2 className="text-3xl md:text-5xl font-bold text-white mb-4">
              How It Works
            </h2>
            <p className="text-white/60 text-lg">
              Simple steps to start your cleaning adventure
            </p>
          </motion.div>

          <div className="grid md:grid-cols-3 gap-8 max-w-4xl mx-auto">
            {[
              {
                step: "1",
                title: "Sign Up",
                description: "Create a family account and add your children's profiles",
                icon: <Users className="w-6 h-6" />,
              },
              {
                step: "2",
                title: "Assign Tasks",
                description: "Parents assign cleaning tasks with point values",
                icon: <CheckCircle2 className="w-6 h-6" />,
              },
              {
                step: "3",
                title: "Clean & Earn",
                description: "Kids complete tasks and watch their room transform!",
                icon: <Zap className="w-6 h-6" />,
              },
            ].map((item, i) => (
              <motion.div
                key={i}
                className="relative text-center"
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.2 }}
              >
                <div className="w-16 h-16 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white text-2xl font-bold mx-auto mb-4 shadow-lg shadow-purple-500/30">
                  {item.step}
                </div>
                <h3 className="text-xl font-bold text-white mb-2">{item.title}</h3>
                <p className="text-white/60">{item.description}</p>

                {i < 2 && (
                  <div className="hidden md:block absolute top-8 left-[60%] w-[80%] h-0.5 bg-gradient-to-r from-purple-500/50 to-transparent" />
                )}
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="relative z-10 py-20">
        <div className="container mx-auto px-6">
          <motion.div
            className="bg-gradient-to-r from-purple-600 to-pink-600 rounded-3xl p-12 text-center relative overflow-hidden"
            initial={{ opacity: 0, scale: 0.95 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
          >
            {/* Background decoration */}
            <div className="absolute inset-0 overflow-hidden">
              {ctaDecorationPositions.map((pos, i) => (
                <motion.div
                  key={i}
                  className="absolute text-4xl opacity-20"
                  style={{
                    left: `${pos.left}%`,
                    top: `${pos.top}%`,
                  }}
                  animate={{ rotate: 360 }}
                  transition={{ duration: 10 + (i % 5) * 2, repeat: Infinity, ease: "linear" }}
                >
                  {['✨', '⭐', '🏠', '🎮', '🏆'][i % 5]}
                </motion.div>
              ))}
            </div>

            <div className="relative">
              <h2 className="text-3xl md:text-5xl font-bold text-white mb-4">
                Ready to Make Cleaning Fun?
              </h2>
              <p className="text-white/80 text-lg mb-8 max-w-2xl mx-auto">
                Join thousands of families who have transformed chore time into game time!
              </p>
              <Link
                href="/register"
                className="inline-flex items-center gap-2 bg-white text-purple-600 px-8 py-4 rounded-2xl font-bold text-lg shadow-2xl hover:shadow-white/30 hover:-translate-y-1 transition-all duration-300"
              >
                Get Started Free
                <ArrowRight className="w-5 h-5" />
              </Link>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="relative z-10 py-12 border-t border-white/10">
        <div className="container mx-auto px-6">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-gradient-to-br from-purple-400 to-pink-400 rounded-lg flex items-center justify-center">
                <Home className="w-5 h-5 text-white" />
              </div>
              <span className="text-white font-semibold">Tidy Room Simulator</span>
            </div>
            <div className="flex items-center gap-6 text-white/60 text-sm">
              <Link href="/privacy" className="hover:text-white transition-colors">Privacy</Link>
              <Link href="/terms" className="hover:text-white transition-colors">Terms</Link>
              <Link href="/contact" className="hover:text-white transition-colors">Contact</Link>
            </div>
            <div className="flex items-center gap-2 text-white/40 text-sm">
              <Shield className="w-4 h-4" />
              <span>Safe for Kids</span>
            </div>
          </div>
          <div className="text-center mt-8 text-white/40 text-sm">
            © 2024 Tidy Room Simulator. Made with ❤️ for families.
          </div>
        </div>
      </footer>
    </div>
  );
}
