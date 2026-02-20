import { GameViewModel } from '../../viewmodel/GameViewModel';
import { GameRenderer } from '../components/GameRenderer';
import { ScoreRepository } from '../../model/repository/ScoreRepository';
import { GameState } from '../../model/entities/GameState';
import { GameConstants } from '../../common/constants/GameConstants';
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';

/**
 * 游戏页 - Canvas绑定ViewModel
 */
@Entry
@Component
struct GamePage {
  @State private viewModel: GameViewModel = new GameViewModel();
  private renderer: GameRenderer = new GameRenderer();
  private scoreRepository: ScoreRepository | null = null;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    // 获取 ScoreRepository
    this.scoreRepository = AppStorage.get<ScoreRepository>('scoreRepository') as ScoreRepository;

    // 加载最高分
    if (this.scoreRepository) {
      this.viewModel.setHighScore(this.scoreRepository.getHighScore());
    }
  }

  aboutToDisappear(): void {
    // 清理资源
    this.viewModel.destroy();
  }

  build() {
    Column() {
      // 游戏画布
      Canvas(this.canvasContext)
        .width(GameConstants.CANVAS_WIDTH)
        .height(GameConstants.CANVAS_HEIGHT)
        .backgroundColor(GameConstants.COLOR_SKY)
        .onReady(() => {
          this.onCanvasReady();
        })
        .onClick(() => {
          this.onCanvasClick();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#333333')
  }

  /**
   * Canvas准备完成
   */
  private onCanvasReady(): void {
    // 开始渲染循环
    this.startRenderLoop();
  }

  /**
   * Canvas点击事件
   */
  private onCanvasClick(): void {
    if (this.viewModel.getGameState() === GameState.IDLE) {
      // 开始游戏
      this.viewModel.startGame();
    } else if (this.viewModel.getGameState() === GameState.PLAYING) {
      // 跳跃
      this.viewModel.jump();
    } else if (this.viewModel.getGameState() === GameState.GAME_OVER) {
      // 重新开始
      this.restartGame();
    }
  }

  /**
   * 开始渲染循环
   */
  private startRenderLoop(): void {
    // 使用 setInterval 实现渲染循环
    setInterval(() => {
      this.render();
    }, 1000 / 60); // 60 FPS
  }

  /**
   * 渲染游戏画面
   */
  private render(): void {
    this.renderer.render(
      this.canvasContext,
      this.viewModel.bird,
      this.viewModel.pipes,
      this.viewModel.score,
      this.viewModel.gameState,
      this.viewModel.groundY
    );
  }

  /**
   * 重新开始游戏
   */
  private async restartGame(): Promise<void> {
    // 保存分数
    if (this.scoreRepository) {
      const isNewHighScore = await this.scoreRepository.saveHighScore(this.viewModel.getScore());
      if (isNewHighScore) {
        this.viewModel.setHighScore(this.viewModel.getScore());
      }
    }

    // 重置游戏
    this.viewModel.restartGame();
  }
}
