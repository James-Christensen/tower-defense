# Game Improvements Roadmap

This document outlines planned improvements to enhance gameplay, UI, and core loop of the tower defense game.

---

## 1. Turret Range & Upgrade Preview System

**Problem**: Players have no visual feedback about turret effectiveness before/after placement or upgrades.

**Solution**:
- Show detection range circle when hoverGreating over grass tiles (before placement)
- Display turret info panel when clicking turrets: current stats, upgrade cost, next level stats
- Show range visualization when selecting turrets
- Add confirmation dialog for major upgrades (like SimpleCannon → RocketLauncher)

**Impact**: Reduces trial-and-error, adds strategic planning depth

**Status**: ✅ Turret info panel (In Progress) | ⏳ Range visualization (Planned)

---

## 2. Balanced Starting Economy & Progressive Costs

**Problem**: Starting with 999 coins removes early-game tension and economic decision-making.

**Solution**:
- Reduce starting coins to 200-300 (enough for 2-3 turrets)
- Implement escalating costs: Base turret 100 → Upgrades: 75, 150, 300, 500
- Add wave completion bonuses (Wave 1: +100, Wave 2: +150, Wave 3: +200)
- Increase mob coin drops slightly to compensate (5-10 coins per mob)

**Impact**: Creates meaningful economic choices and tension

**Status**: ⏳ Planned

---

## 3. Turret Selling & Repositioning System

**Problem**: Once placed, turrets are permanent - mistakes are costly and remove strategic flexibility.

**Solution**:
- Right-click or dedicated UI button to sell turrets for 60-70% refund
- Visual confirmation showing refund amount
- Allow selling even when upgraded (get back partial upgrade costs)
- Add tooltip hint on first turret placement

**Impact**: Reduces player frustration, adds strategic repositioning options

**Status**: ✅ In Progress

---

## 4. Wave Variety & Difficulty Progression

**Problem**: All 3 waves use identical zombie types, wave 3 has missing configuration, difficulty doesn't scale meaningfully.

**Solution**:
- Fix wave 3 configuration (currently missing `num_mobs`, defaulting to 10)
- Create mob variants:
  - **Fast Zombie**: 150 speed, 60 HP, 3-5 coins (wave 2+)
  - **Tank Zombie**: 60 speed, 200 HP, 8-12 coins (wave 3+)
- Proper wave scaling: Wave 1 (5 normal), Wave 2 (7 mixed), Wave 3 (12 mixed with tanks)
- Add mini-boss every 3rd wave with special rewards

**Impact**: Keeps gameplay engaging, requires turret positioning strategy

**Status**: ⏳ Planned

---

## 5. Visual Affordability & Range Indicators

**Problem**: No visual feedback about what player can afford until clicking and losing money.

**Solution**:
- Green glow/outline on grass tiles when hovering and can afford turret
- Red tint when hovering but insufficient coins
- Show cost tooltip near cursor when hovering placeable areas
- Turrets pulse green when affordable to upgrade, gray when not
- Add range circles that appear on hover (semi-transparent)

**Impact**: Dramatically improves UX, reduces frustration, feels more polished

**Status**: ⏳ Planned

---

## Quick Wins (Bonus Features)

- [ ] Fix starting coins from 999 to reasonable value (~250)
- [ ] Fix wave 3 `num_mobs` configuration
- [ ] Add "Next Wave" button to skip wave_delay waiting period
- [ ] Add sound effects for placement, upgrades, and insufficient funds
- [ ] Add keyboard shortcuts (ESC to close panels, SPACE to start next wave)

---

## Implementation Priority

1. **Phase 1** (Current): Turret Purchase/Upgrade/Sell UI - Foundation for many other features
2. **Phase 2**: Visual affordability indicators - Major UX improvement
3. **Phase 3**: Economy rebalancing - Core gameplay enhancement
4. **Phase 4**: Wave variety - Content expansion
5. **Phase 5**: Range visualization - Polish and strategy depth

---

## Notes

- Keep changes modular and testable
- Maintain compatibility with GDQuest practice system
- Focus on simplicity and maintainability
- Each feature should work independently

---

*Last Updated: 2025-10-14*
