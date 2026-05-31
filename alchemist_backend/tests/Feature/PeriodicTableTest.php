<?php

namespace Tests\Feature;

use App\Models\PeriodicArticle;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PeriodicTableTest extends TestCase
{
    use RefreshDatabase;

    public function test_periodic_table_view_loads()
    {
        $user = User::factory()->create();
        $response = $this->actingAs($user)->get('/periodic-table');
        $response->assertStatus(200);
        $response->assertViewIs('periodic_table');
    }

    public function test_get_all_periodic_articles()
    {
        PeriodicArticle::create([
            'element_number' => 1,
            'element_symbol' => 'H',
            'description' => 'Hydrogen test',
            'image_url' => 'https://example.com/h.jpg',
            'model_3d_url' => 'https://example.com/h.glb',
            'content' => 'Test content',
        ]);

        $response = $this->get('/api/periodic-articles');
        $response->assertStatus(200);
        $response->assertJsonCount(1);
    }

    public function test_get_specific_periodic_article()
    {
        PeriodicArticle::create([
            'element_number' => 1,
            'element_symbol' => 'H',
            'description' => 'Hydrogen',
            'image_url' => 'https://example.com/h.jpg',
        ]);

        $response = $this->get('/api/periodic-articles/1');
        $response->assertStatus(200);
        $response->assertJsonFragment(['element_symbol' => 'H']);
    }

    public function test_create_periodic_article()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/periodic-articles', [
            'element_number' => 2,
            'element_symbol' => 'He',
            'description' => 'Helium element',
            'image_url' => 'https://example.com/he.jpg',
            'model_3d_url' => 'https://example.com/he.glb',
            'content' => 'Helium content',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('periodic_articles', [
            'element_number' => 2,
            'element_symbol' => 'He',
        ]);
    }

    public function test_update_periodic_article()
    {
        $user = User::factory()->create();

        PeriodicArticle::create([
            'element_number' => 3,
            'element_symbol' => 'Li',
            'description' => 'Old description',
        ]);

        $response = $this->actingAs($user)->postJson('/api/periodic-articles', [
            'element_number' => 3,
            'element_symbol' => 'Li',
            'description' => 'Updated description',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('periodic_articles', [
            'element_number' => 3,
            'description' => 'Updated description',
        ]);
    }

    public function test_delete_periodic_article()
    {
        $user = User::factory()->create();

        PeriodicArticle::create([
            'element_number' => 4,
            'element_symbol' => 'Be',
            'description' => 'Beryllium',
        ]);

        $response = $this->actingAs($user)->deleteJson('/api/periodic-articles/4');
        $response->assertStatus(200);
        $this->assertDatabaseMissing('periodic_articles', [
            'element_number' => 4,
        ]);
    }

    public function test_invalid_element_number()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->postJson('/api/periodic-articles', [
            'element_number' => 999,
            'element_symbol' => 'Xx',
        ]);

        $response->assertStatus(422);
    }
}
