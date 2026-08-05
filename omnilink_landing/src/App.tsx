import Nav from './components/Nav'
import { Hero } from './components/Hero'
import ProblemStatement from './components/ProblemStatement'
import { Pillars } from './components/Pillars'
import { FileTypeShowcase } from './components/FileTypeShowcase'
import { RealtimeStream } from './components/RealtimeStream'
import Organization from './components/Organization'
import Security from './components/Security'
import CTA from './components/CTA'
import Footer from './components/Footer'
import { AnimatedBackground } from './components/ui/AnimatedBackground'

function App() {
  return (
    <AnimatedBackground>
      <div className="min-h-screen bg-surface">
        <Nav />
        <main>
          <Hero />
          <ProblemStatement />
          <div id="features">
            <Pillars />
          </div>
          <div id="file-types">
            <FileTypeShowcase />
          </div>
          <div id="how-it-works">
            <RealtimeStream />
          </div>
          <Organization />
          <Security />
          <CTA />
        </main>
        <Footer />
      </div>
    </AnimatedBackground>
  )
}

export default App
