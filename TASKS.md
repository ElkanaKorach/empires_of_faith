# Empires of Faith — Task List

**Kategorie:**
- 🎯 = Feature
- 🐛 = Bug
- 🔧 = Tech Debt
- 🎮 = Gameplay
- 🌍 = Content

---

## 🔴 Hohe Priorität (MVP)

### 🎮 Gameplay
- [ ] **Einheiten-Bewegung** — Punkt-klick Bewegung mit Pathfinding (A* ist vorhanden, testen ob es funktioniert)
- [ ] **Auswahl-System** — Einheiten selektieren, Multi-Select mit Shift, Box-Select
- [ ] **Gebäude platzieren** — Placement-Modus für Strukturen
- [ ] **Ressourcen-System** — Sammeln, Lagern, Ausgeben von Ressourcen
- [ ] **Produktion** — Einheiten in Gebäuden produzieren (Queue)

### 🌍 Content
- [ ] **Karte/Map** — Mindestens 1 spielbare Map für Prototype
- [ ] **Start-Assets** — minimaler Einheiten-Starter-Satz pro Fraktion

---

## 🟡 Mittlere Priorität

### 🎮 Gameplay
- [ ] **Kampf-System** — Angriffsreichweite, Schaden, Tod
- [ ] **KI Gegner** — basis KI die Einheiten produziert und angreift
- [ ] **Map-System** — Scrollen, Zoom, Kamera-Bewegung (RTS-Kamera ist laut TODO vorhanden)
- [ ] **Lobby-System** — Raum erstellen, beitreten, starten
- [ ] **Save/Load** — Spielstand speichern und laden

### 🔧 Tech
- [ ] **WebGL Export testen** — funktioniert der Export überhaupt?
- [ ] **Multiplayer-Kommunikation** — WebRTC Verbindung testen
- [ ] **UI Polish** — HUD, Menüs, Buttons, Feedback

---

## 🟢 Niedrige Priorität / Nice-to-have

### 🎮 Gameplay
- [ ] **5 Fraktionen** — Nation Data vorhanden, aber gibt es unterschiedliche Einheiten/Stats?
- [ ] **Campaign System** — laut TODO vorhanden, aber was genau?
- [ ] **Sound-Integration** — Audio-Background, SFX für Aktionen

### 🌍 Content
- [ ] **Mehr Maps** — verschiedene Terrain-Typen
- [ ] **Animationen** — Einheiten-Animationen, Gebaude-Aufbau

### 🔧 Tech
- [ ] **Performance** — viele Einheiten auf der Map, Optimization
- [ ] **Mobile Support** — Touch-Controls für mobile Geräte

---

## 🎯 Langfristig / Konzept

- [ ] **Multiplayer Vollversion** — lobby, matchmaking, ranks
- [ ] **KI-Gegner Schwierigkeitsgrade**
- [ ] **Replay-System**
- [ ] **Mod-Support** — eigene Maps, eigene Fraktionen

---

## Status-Check

| Modul | Status |
|-------|--------|
| Projektstruktur | ✅ |
| GameManager | ✅ |
| Entity/Unit/Building | ✅ |
| Nation Data (5) | ✅ |
| RTS Kamera | ✅ |
| Pathfinding (A*) | ✅ |
| KI Controller | ⚠️ ungetestet |
| Multiplayer Basis | ⚠️ ungetestet |
| Resource Manager | ⚠️ ungetestet |
| Combat Manager | ⚠️ ungetestet |
| Main Menu | ⚠️ ungetestet |
| Game Scene | ⚠️ ungetestet |
| HUD | ⚠️ ungetestet |
| Map-System | ❓ fehlt |
| Selection System | ❓ unvollständig |
| Production System | ❓ unvollständig |
| Save/Load | ❌ fehlt |
| Sound | ❌ fehlt |
| Campaign | ❌ unklar |

---

## Nächster Schritt

**Testen:** Kann das Spiel gestartet werden? Gibt es eine main_menu.tscn die funktioniert? Die Dateien auf GitHub sind nur die Meta-Files — die eigentlichen .gd Scripts und .tscn Scenes fehlen noch.