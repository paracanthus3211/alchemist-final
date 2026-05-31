<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Avatar;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AvatarAdminController extends Controller
{
    public function index()
    {
        $avatars = Avatar::latest()->get();
        return view('admin.avatars.index', compact('avatars'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,svg,webp|max:2048',
            'unlock_type' => 'required|in:xp,streak,special',
            'unlock_value' => 'required|integer|min:0',
            'rarity' => 'required|string',
        ]);

        $avatar = new Avatar();
        $avatar->name = $request->name;
        $avatar->description = $request->description;
        $avatar->unlock_type = $request->unlock_type;
        $avatar->unlock_value = $request->unlock_value;
        $avatar->rarity = $request->rarity;

        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->move(public_path('images/avatars'), $filename);
            $avatar->image_url = '/images/avatars/' . $filename;
        }

        $avatar->save();

        return redirect()->route('admin.avatars.index')->with('success', 'Avatar created successfully.');
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg,webp|max:2048',
            'unlock_type' => 'required|in:xp,streak,special',
            'unlock_value' => 'required|integer|min:0',
            'rarity' => 'required|string',
        ]);

        $avatar = Avatar::findOrFail($id);
        $avatar->name = $request->name;
        $avatar->description = $request->description;
        $avatar->unlock_type = $request->unlock_type;
        $avatar->unlock_value = $request->unlock_value;
        $avatar->rarity = $request->rarity;

        if ($request->hasFile('image')) {
            // Option to delete old file can go here
            $file = $request->file('image');
            $filename = time() . '_' . $file->getClientOriginalName();
            $file->move(public_path('images/avatars'), $filename);
            $avatar->image_url = '/images/avatars/' . $filename;
        }

        $avatar->save();

        return redirect()->route('admin.avatars.index')->with('success', 'Avatar updated successfully.');
    }

    public function destroy($id)
    {
        $avatar = Avatar::findOrFail($id);
        // Option to delete old file can go here
        $avatar->delete();

        return redirect()->route('admin.avatars.index')->with('success', 'Avatar deleted successfully.');
    }
}

